Class {
	#name : #PBManager,
	#superclass : #Object,
	#classVars : [
		#IsRunning
	],
	#category : #'PythonBridge-Pharo'
}

{ #category : #configuration }
PBManager class >> bridgeDirectory [
    ^ PBPlatform current folderForApplication: PBApplication new
]

{ #category : #configuration }
PBManager class >> checkPythonDependencies [
    "Verifica che Python3 e le dipendenze siano disponibili."
    | process result |
    process := OSSUnixSubprocess new
        command: self python3Path;
        arguments: #('-c' 'import flask; import requests; import msgpack; print("OK")');
        redirectStdout;
        redirectStderr;
        yourself.
    process runAndWaitOnExitDo: [:p :out :err |
        result := p exitStatusInterpreter exitStatus = 0
            ifTrue: [ 'Python dependencies OK' ]
            ifFalse: [ 'ERRORE: ', err trimBoth ]].
    ^ result
]

{ #category : #execution }
PBManager class >> do: aBlock [
    "Accesso diretto a PBApplication do: per usi avanzati con PBCF."
    ^ PBApplication do: aBlock
]

{ #category : #execution }
PBManager class >> execute: aPythonExpression [
    "Esegue un'espressione Python e ritorna il valore.
     Il bridge deve essere in esecuzione (vedi PBManager start).
     BLOCCANTE: blocca l'UI fino alla risposta.
     Esempio: PBManager execute: '1 + 2' => 3"
    ^ PBApplication do: [
        PBCF << ('eval' asP3GIdentifier callWith: { aPythonExpression }).
        PBCF sendAndWait ]
]

{ #category : #execution }
PBManager class >> executeAsync: aPythonExpression [
    "Esegue un'espressione Python in un processo separato senza bloccare l'UI.
     Il risultato viene stampato nel Transcript.
     Esempio: PBManager executeAsync: '2+3'"
    self executeAsync: aPythonExpression then: [ :r |
        Transcript show: 'Python => '; show: r asString; cr ]
]

{ #category : #execution }
PBManager class >> executeAsync: aPythonExpression then: aBlock [
    "Esegue un'espressione Python in un processo separato senza bloccare l'UI.
     Quando il risultato arriva, esegue aBlock con il risultato.
     Esempio: PBManager executeAsync: '2+3' then: [:r | Transcript show: r asString; cr]"
    [ | result |
      result := self execute: aPythonExpression.
      aBlock value: result
    ] fork
]

{ #category : #status }
PBManager class >> isRunning [
    ^ [PBApplication isRunning] on: Error do: [:e | false]
]

{ #category : #configuration }
PBManager class >> python3Path [
    ^ PBDirectPythonProcess python3Path
]

{ #category : #configuration }
PBManager class >> python3Path: aString [
    PBDirectPythonProcess python3Path: aString
]

{ #category : #execution }
PBManager class >> run: aPythonStatement [
    "Esegue uno statement Python (import, assegnamento, ecc).
     Per ottenere un valore, usare execute:.
     BLOCCANTE: blocca l'UI fino alla risposta.
     Esempio: PBManager run: 'import numpy as np'"
    ^ PBApplication do: [
        PBCF << ('exec' asP3GIdentifier callWith: { aPythonStatement }).
        PBCF sendAndWait ]
]

{ #category : #'start-stop' }
PBManager class >> start [
    "Avvia PythonBridge. Ritorna self o segnala errore."
    PBApplication start.
    IsRunning := true.
    ^ self
]

{ #category : #status }
PBManager class >> status [
    "Ritorna un dizionario con lo stato completo. Utile per Claude e per la UI."
    | dict |
    dict := Dictionary new.
    dict at: #isRunning put: self isRunning.
    dict at: #python3Path put: self python3Path.
    dict at: #bridgeDirectory put: self bridgeDirectory fullName.
    dict at: #processStrategy put: PBPlatform current processStrategy name.
    dict at: #messageBrokerStrategy put: PBPlatform current messageBrokerStrategy name.
    ^ dict
]

{ #category : #status }
PBManager class >> statusReport [
    "Ritorna una stringa con lo stato completo, leggibile da umani."
    | s status |
    status := self status.
    s := WriteStream on: String new.
    s nextPutAll: '=== PythonBridge Status ==='; cr; cr.
    s nextPutAll: 'Running: '; nextPutAll: (status at: #isRunning) asString; cr.
    s nextPutAll: 'Python3: '; nextPutAll: (status at: #python3Path); cr.
    s nextPutAll: 'Bridge dir: '; nextPutAll: (status at: #bridgeDirectory); cr.
    s nextPutAll: 'Process: '; nextPutAll: (status at: #processStrategy); cr.
    s nextPutAll: 'Broker: '; nextPutAll: (status at: #messageBrokerStrategy); cr.
    s nextPutAll: 'Dependencies: '; nextPutAll: self checkPythonDependencies; cr.
    ^ s contents
]

{ #category : #'start-stop' }
PBManager class >> stop [
    "Ferma PythonBridge."
    [PBApplication stop] on: Error do: [:e | ].
    IsRunning := false.
    ^ self
]
