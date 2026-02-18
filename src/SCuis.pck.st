'From Cuis7.2 [latest update: #6897] on 18 February 2026 at 8:55:57 pm'!
'Description '!
!provides: 'SCuis' 1 51!
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

!SCuis methodsFor: 'evaluation' stamp: 'ct 2/18/2026 20:55:16'!
evaluate
	" I evaluate the given script (only the first script is evalued) "
	| headMode daemonMode |

	headMode := SCuisEnv HEAD.
	daemonMode := SCuisEnv DAEMON.
	
	[ 
		| args script |

		args := SCuisEnv ARGS.	
		((args = nil) or: (args = '')) ifFalse: [
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
			]
		].
	
	 	(args = '') ifTrue: [  "no ARGS given"
			| isAdoc |
			
			isAdoc := CtuMem getenv: 'SCUIS_ADOC'.
			
			((isAdoc ~= '') and: (isAdoc notNil)) ifTrue: [
				" if called from an asciidoc document "
				self evaluateAsciidoc: headMode.
			].
		].
			
	] on: Error do: [ :err | 
		(headMode = 'yes') ifTrue: [
			self halt.
		].
		
		CtuMem print: (err messageText); nl.
	].

	((headMode = 'no') and: (daemonMode = 'no')) ifTrue: [
		Smalltalk quit.	
	].! !

!SCuis methodsFor: 'asciidoc - private' stamp: 'ct 2/7/2026 19:00:39'!
extractAsciidoc: adocName sourceBlock: sourceId
	| adocFile foundBlockLines isInside line scuisIdLine isCuisSource |
	
	foundBlockLines := OrderedCollection new.
	scuisIdLine := ''.
	isInside := false.
	isCuisSource := false.
		
	adocFile := ((SCuisEnv PWD), '/', adocName) asFileEntry readStream.

	[	
		[adocFile atEnd] whileFalse: [
			line := adocFile nextLine.

			isInside ifTrue: [
				(scuisIdLine = sourceId) ifTrue: [
					isCuisSource := true.
				].
			
				(line = '----') ifTrue: [
					isCuisSource := false.
					isInside := false.	
				].
			
				isCuisSource ifTrue: [
					foundBlockLines add: line.
				].
			].

			(line = '[source,smalltalk]') ifTrue: [
				line := adocFile nextLine.		"Should be: ----"	
				line := adocFile nextLine.
				scuisIdLine := line.			
				isInside := true.
			].
		].
	] ensure: [	
		adocFile close.
	].

	^foundBlockLines.! !

!SCuis methodsFor: 'asciidoc' stamp: 'ct 2/7/2026 20:55:26'!
evaluateAsciidoc: headMode
	"Should come with the env variable SCUIS_ADOC=<file>.adoc,<source block id>
	  In the first row of the asciidoc source block add the id like scuis=<source block id>
	
	  Example asciidoc (the file name is test.adoc):
	  [source,smalltalk]
	  ----
	  scuis=c1
	  ----
	
	  [source,bash]
	  ----
	  SCUIS_ADOC=test,c1 cuis
	  ----
	"
	| adocName sourceId env foundBlockLines |
	
	env := (CtuMem getenv: 'SCUIS_ADOC') findTokens: ','.
	
	adocName := (env at: 1), '.adoc'.
	sourceId := 'scuis=', (env at: 2).
	foundBlockLines := self extractAsciidoc: adocName sourceBlock: sourceId.
	
	(headMode = 'yes') ifFalse: [
		| content |
		content := ''.
		
		foundBlockLines do: [ :line |
			(line beginsWith: 'SCuis require:') ifTrue: [
			self processRequirement: line.
			] ifFalse: [
				content := content, line.
			].	
		].
	
		self processContent: content.
	] ifTrue: [
		| content |
		content := ''.
		foundBlockLines do: [ :line |
			content := content, line, (String lfString).
		].
		Workspace new contents: content; openLabel: 'Asciidoc code block'.
	].
	! !

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

!SCuisEnv class methodsFor: 'as yet unclassified' stamp: 'ct 2/18/2026 20:54:03'!
DAEMON
	^CtuMem getenv: 'SCUIS_DAEMON'.! !

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
