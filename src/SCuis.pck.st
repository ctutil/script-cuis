'From Cuis7.2 [latest update: #6897] on 1 February 2026 at 8:02:29 pm'!
'Description '!
!provides: 'SCuis' 1 21!
!requires: 'CtuMem' 1 66 nil!
SystemOrganization addCategory: #scuis!


!classDefinition: #SCuis category: #scuis!
Object subclass: #SCuis
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'scuis'!
!classDefinition: 'SCuis class' category: #scuis!
SCuis class
	instanceVariableNames: ''!

!classDefinition: #SCuisEnv category: #scuis!
Object subclass: #SCuisEnv
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'scuis'!
!classDefinition: 'SCuisEnv class' category: #scuis!
SCuisEnv class
	instanceVariableNames: ''!


!SCuis methodsFor: 'private' stamp: 'ct 2/1/2026 19:38:03'!
processContent: scriptContent
	Compiler evaluate: scriptContent.! !

!SCuis methodsFor: 'private' stamp: 'ct 2/1/2026 16:31:53'!
processRequirement: aLine
	Compiler evaluate: aLine.! !

!SCuis methodsFor: 'evaluation' stamp: 'ct 2/1/2026 20:02:21'!
evaluate
	" I evaluate the given script (only the first script is evalued) "
	| headMode |

	headMode := SCuisEnv HEAD.
	
	[ 
		| args script |

		args := SCuisEnv ARGS.	
		(args = nil) ifFalse: [
			| nextLine content |
			content := ''.
			script := args asFileEntry readStream.
			[
				[script atEnd] whileFalse: [
					nextLine := script nextLine.
					(nextLine beginsWith: '#!!') ifFalse: [
						(nextLine beginsWith: 'SCuis require:') ifTrue: [
							self processRequirement: nextLine.
						] ifFalse: [
							content := content, nextLine.
						].
					].
				].
			
				(content = '') ifFalse: [
					(headMode = 'yes') ifTrue: [
						Workspace new contents: content; openLabel: args.
					] ifFalse: [
						self processContent: content.
					].
				].
			]
			ensure: [
				script ifNotNil: [script close].
			].
		].
			
	] on: Error do: [ :err | 
		CtuMem print: (err messageText); nl.
	].

	(headMode = 'no') ifTrue: [
		Smalltalk quit.	
	].! !

!SCuis class methodsFor: 'requirements' stamp: 'ct 2/1/2026 14:29:43'!
require: aFeatureName
	"A feature name without full path and extension"
	Feature require: (SCuisEnv PWD), '/', aFeatureName, '.pck.st'.! !

!SCuisEnv class methodsFor: 'as yet unclassified' stamp: 'ct 2/1/2026 13:56:38'!
ARGS
	^CtuMem getenv: 'SCUIS_ARGS'.! !

!SCuisEnv class methodsFor: 'as yet unclassified' stamp: 'ct 2/1/2026 13:57:10'!
CLEAR_CACHE
	^CtuMem getenv: 'SCUIS_CLEAR_CACHE'.! !

!SCuisEnv class methodsFor: 'as yet unclassified' stamp: 'ct 2/1/2026 13:58:03'!
HEAD
	^CtuMem getenv: 'SCUIS_HEAD'.! !

!SCuisEnv class methodsFor: 'as yet unclassified' stamp: 'ct 2/1/2026 14:03:28'!
PRINT_ENV
	^CtuMem getenv: 'SCUIS_PRINT_ENV'.! !

!SCuisEnv class methodsFor: 'as yet unclassified' stamp: 'ct 2/1/2026 14:04:05'!
PWD
	^CtuMem getenv: 'SCUIS_PWD'.! !

!SCuisEnv class methodsFor: 'as yet unclassified' stamp: 'ct 2/1/2026 14:06:52'!
STATE_DIR
	^CtuMem getenv: 'SCUIS_STATE_DIR'.! !

!SCuisEnv class methodsFor: 'as yet unclassified' stamp: 'ct 2/1/2026 14:11:04'!
VM_ARGS
	^CtuMem getenv: 'SCUIS_VM_ARGS'.! !
