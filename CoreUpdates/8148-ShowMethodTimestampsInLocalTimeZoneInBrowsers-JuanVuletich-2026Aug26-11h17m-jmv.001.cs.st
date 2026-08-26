'From Cuis7.9 [latest update: #8147] on 26 August 2026 at 11:40:05 am'!

!CompiledMethod methodsFor: 'time stamp' stamp: 'jmv 26/Aug/2026, 2:37:12 pm (UTC)'!
authorAndStampLocalTZ
	"Answer the authoring time-stamp for the given method, retrieved from the sources or changes file.
	Answer the empty string if no time stamp is available.
	Format the date in the timestamp with the preferred style.
	(Object compiledMethodAt: #printString) authorAndStampAsSaved
	(Object compiledMethodAt: #printString) authorAndStamp
	"
	| asSaved |
	asSaved := self authorAndStampAsSaved.
	asSaved isEmpty ifTrue: [ ^asSaved ].
	^String streamContents: [ :strm | 
		self class authorAndStamp: asSaved partsDo: [ :authorInitials :dateAndTime |
			strm nextPutAll: authorInitials.
			strm space.
			dateAndTime printNiceLocalTimeZoneOn: strm ]]! !

!CompiledMethod methodsFor: 'time stamp' stamp: 'jmv 26/Aug/2026, 2:27:16 pm (UTC)'!
authorAndStampUTC
	"Answer the authoring time-stamp for the given method, retrieved from the sources or changes file.
	Answer the empty string if no time stamp is available.
	Format the date in the timestamp with the preferred style.
	(Object compiledMethodAt: #printString) authorAndStampAsSaved
	(Object compiledMethodAt: #printString) authorAndStamp
	"
	| asSaved |
	asSaved := self authorAndStampAsSaved.
	asSaved isEmpty ifTrue: [ ^asSaved ].
	^String streamContents: [ :strm | 
		self class authorAndStamp: asSaved partsDo: [ :authorInitials :dateAndTime |
			strm nextPutAll: authorInitials.
			strm space.
			dateAndTime asUTC printNiceOn: strm ]]! !


!CodeProvider methodsFor: 'message list menu' stamp: 'jmv 26/Aug/2026, 2:30:46 pm (UTC)'!
timeStampString
	"Answer the time stamp for the chosen class and method, if any, else an empty string"

	|  selector  |
	(selector := self selectedMessageName) ifNotNil: [
		^self selectedClassOrMetaClass 
			ifNil: [
				String new]
			ifNotNil: [
				self selectedClassOrMetaClass stampAt: selector]].
	^ String new! !


!DateAndTime methodsFor: 'ansi protocol' stamp: 'jmv 26/Aug/2026, 2:25:00 pm (UTC)'!
asLocalTimeZone

	^ self utcOffset: UtcOffsetInSeconds seconds! !

!DateAndTime methodsFor: 'public protocol' stamp: 'jmv 26/Aug/2026, 2:27:00 pm (UTC)'!
printNiceLocalTimeZoneOn: aStream
	"Print a nice human readable format.
	String streamContents: [ :strm | DateAndTime now printNiceLocalTimeZoneOn: strm ]
		 '26/Aug/2026, 11:26:52 am' .
	String streamContents: [ :strm | DateAndTime nowUTC printNiceLocalTimeZoneOn: strm ]
		'26/Aug/2026, 11:26:44 am' .
	"
	| inLocalTimeZone |
	inLocalTimeZone := self asLocalTimeZone.
	inLocalTimeZone date printOn: aStream format: #(1 2 3 $/  2 1 ).
	aStream nextPutAll: ', '.
	inLocalTimeZone time print24: false on: aStream.! !


!Behavior methodsFor: 'methods' stamp: 'jmv 26/Aug/2026, 2:36:39 pm (UTC)'!
stampAt: selector
	^(self compiledMethodAt: selector ifAbsent: [ ^'' ]) authorAndStampLocalTZ! !


!ClassDescription methodsFor: 'fileIn/Out' stamp: 'jmv 26/Aug/2026, 2:38:33 pm (UTC)'!
printMethodChunk: selector withPreamble: doPreamble on: outStream moveSource: moveSource toFile: fileIndex
	"Copy the source code for the method associated with selector onto the fileStream.
	If moveSource true, then also set the source code pointer of the method."

	| compiledMethod oldPos newPos sourceFile endPos methodCode methodCodeText codeStyler |
	compiledMethod := self methodDict at: selector ifAbsent: [
		outStream nextPutAll: selector; newLine.
		outStream tab; nextPutAll: '** ERROR  -  THIS METHOD IS MISSING ** '; newLine; newLine.
		outStream nextPutAll: '  '.
		^ outStream].

	doPreamble ifTrue: [
		self
			printCategoryChunk: (self organization categoryOfElement: selector)
			on: outStream
			withStamp: compiledMethod authorAndStampUTC
			priorMethod: nil.
		compiledMethod
			withPropertiesDo: [ :properties |
				properties hasAnyProperty ifTrue: [
					self printPropertiesChunk: properties on: outStream ]]
			ifSelector: [ :sel | nil ].
		outStream newLine ].

	((compiledMethod fileIndex = 0
		or: [(SourceFiles at: compiledMethod fileIndex) == nil])
		or: [(oldPos := compiledMethod filePosition) = 0])
			ifTrue: [
				"The source code is not accessible.  We must decompile..."
				outStream nextChunkPut: compiledMethod decompileString]
			ifFalse: [
				sourceFile := SourceFiles at: compiledMethod fileIndex.
				sourceFile position: oldPos.
				"Copy the method chunk"
				fileIndex = 0 ifFalse: [
					outStream padTo: SourceFiles pointerScaleForWriting put: $  ].
				newPos := outStream position.
				"Copy method chunk"
				methodCode := sourceFile nextChunk.
				(methodCode isEmpty or: [ methodCode isSeparators ]) ifTrue: [
					"This is very unlikely, but possible source file is corrupted."
					methodCode := compiledMethod decompileString ].
				"Convert method code to use ANSI assignments"
				(Preferences at: #fileOutANSIassignment) ifTrue: [
					codeStyler := SHTextStylerST80 new.
					codeStyler classOrMetaClass: compiledMethod methodClass.
					methodCodeText := methodCode asText.
					codeStyler instVarNamed: 'formattedText' put: methodCodeText.
					codeStyler getReady.
					codeStyler parseText.
					codeStyler replaceStringForRangesWithType: #assignment with: ':=' offset: 0.
					methodCode := methodCodeText string ].
				outStream nextChunkPut: methodCode.
				moveSource ifTrue: [    "Set the new method source pointer"
					endPos := outStream position.
					compiledMethod checkOKToAdd: endPos - newPos at: newPos in: compiledMethod fileIndex.
					compiledMethod setSourcePosition: newPos inFile: fileIndex]].
	doPreamble ifTrue: [ outStream nextChunkPut: ' ' ].
	outStream newLine.
! !


!SystemDictionary methodsFor: 'browsing' stamp: 'jmv 26/Aug/2026, 2:39:05 pm (UTC)'!
browseMyChanges
	"Browse only the changes (in the changes file) by the current author.
	Smalltalk browseMyChanges
	"
	self browseAllSelect: [ :method |
       method fileIndex > 1 "only look at changes file"
               and: [ method authorAndStampAsSaved beginsWith: Utilities authorInitials, ' ' ]]! !


!CodeProvider methodsFor: 'annotation parts' stamp: 'jmv 26/Aug/2026, 2:34:26 pm (UTC)'!
timeStampOf: aClass selector: aSelector printOn: strm
	"Print the #timeStamp method annotation."

	| stamp |
	strm atStart ifFalse: [ strm nextPutAll: self annotationSeparator ].
	stamp := self timeStampString.
	strm nextPutAll: (stamp size > 0 ifTrue: [stamp] ifFalse: ['no timestamp']).
! !


!MethodSet methodsFor: 'filtering' stamp: 'jmv 26/Aug/2026, 2:39:22 pm (UTC)'!
filterToCurrentAuthor
	"Filter down only to messages with my initials as most recent author"

	| myInitials aMethod aTimeStamp |
	(myInitials := Utilities authorInitialsPerSe) ifNil: [^ self inform: 'No author initials set in this image'].
	self filterFrom:
		[:aClass :aSelector |
			(aClass notNil and: [aSelector notNil]) and:			
				[aMethod := aClass compiledMethodAt: aSelector ifAbsent: nil.
				aMethod notNil and:
					[(aTimeStamp := aMethod authorAndStampAsSaved) notNil and:
						[aTimeStamp beginsWith: myInitials]]]]! !

!MethodSet methodsFor: 'filtering' stamp: 'jmv 26/Aug/2026, 2:39:25 pm (UTC)'!
filterToNotCurrentAuthor
	"Filter down only to messages not stamped with my initials"

	| myInitials aMethod aTimeStamp |
	(myInitials := Utilities authorInitialsPerSe) ifNil: [^ self inform: 'No author initials set in this image'].
	self filterFrom:
		[:aClass :aSelector |
			(aClass notNil and: [aSelector notNil]) and:			
				[aMethod := aClass compiledMethodAt: aSelector ifAbsent: nil.
				aMethod notNil and:
					[(aTimeStamp := aMethod authorAndStampAsSaved) isNil or:
						[(aTimeStamp beginsWith: myInitials) not]]]]! !


!ChangeSet methodsFor: 'moving changes' stamp: 'jmv 26/Aug/2026, 2:39:31 pm (UTC)'!
methodsWithInitialsOtherThan: myInits
	"Return a collection of method refs whose author appears to be different from the given one"
	| slips |
	slips := OrderedCollection new.
	self changedClasses do: [ :aClass |
		(self methodChangesAtClass: aClass name) associationsDo: [ :mAssoc | | method |
				(#(remove addedThenRemoved movedToOtherPackage) includes: mAssoc value) ifFalse: [
					method := aClass compiledMethodAt: mAssoc key ifAbsent: nil.
					method ifNotNil: [ | authorAndStamp |
						((authorAndStamp := method authorAndStampAsSaved) notNil and: [
							(authorAndStamp beginsWith: myInits) not])
								ifTrue: [slips add: aClass name , ' ' , mAssoc key]]]]].
	^ slips

	"
	Smalltalk browseMessageList: (ChangeSet changeSetForBaseSystem methodsWithInitialsOtherThan: 'sw') name: 'authoring problems'
	"! !


!PreferenceSet class methodsFor: 'sys data' stamp: 'jmv 26/Aug/2026, 2:31:10 pm (UTC)'!
machineSlow
	^ #(
		(drawKeyboardFocusIndicator false )
		(balloonHelpEnabled false)
		(browseWithPrettyPrint false)
		(caseSensitiveFinds true)
		(checkForSlips false)
		(cmdDotEnabled true)
		(diffsInChangeList true)
		(diffsWithPrettyPrint false)
		(menuKeyboardControl false)
		(optionalButtons false)
		(subPixelRenderFonts true)
		(cheapWindowReframe true)
		(syntaxHighlightingAsYouType false)
		(tapAndHoldEmulatesButton2 false)
		(clickGrabsMorphs true)
		(wantsMenuIcons false )
		(methodAnnotations #(timeStampString messageCategory packages changeSets properties) )
		(classAnnotations  #(instanceMethodsCount classMethodsCount) )
		(systemCategoryAnnotations #(classCount instanceMethodsCount classMethodsCount) )
	)! !

!PreferenceSet class methodsFor: 'sys data' stamp: 'jmv 26/Aug/2026, 2:31:05 pm (UTC)'!
prefProgramming
	^ #(
		#(atMinusDigitMeaning st80 #(st80 ansiSmalltalk disabled) )
		#(allowBlockArgumentAssignment false )
		#(allowNonBooleanReceiversOfBooleanMessages false )
		#(alternativeBrowseIt false )
		#(browseWithPrettyPrint false )
		#(debugHaloHandle true )
		#(debugLogTimestamp true )
		#(debugPreDebugger false )
		#(debugShowDamage false )
		#(decorateBrowserButtons true )
		#(diffsInChangeList true )
		#(diffsWithPrettyPrint false )
		#(extraDebuggerButtons true )
		#(fullPrintItInWorkspaces false )
		#(highlightBlockNesting true )
		#(italicsInShout true)
		#(listClassesHierarchically true )
		#(logDebuggerStackToFile false )
		#(prettyPrintRectangularBlocks false )
		#(shiftClickShowsImplementors false )
		#(shoutInWorkspaces true )
		#(workspacesStyleByParagraphs true )
		#(showAnnotations true )
		#(showLinesInHierarchyViews true )
		#(stylingWithEmphasisInWorkspaces false )
		#(systemCategoryAnnotations #(classCount instanceMethodsCount classMethodsCount "linesOfCode" messageSendsCount) )
		#(classAnnotations #(instanceMethodsCount classMethodsCount "linesOfCode" messageSendsCount) )
		#(messageCategoryAnnotations #(messagesCount messageSendsCount) )
		#(methodAnnotations #(timeStampString "linesOfCode" messageSendsCount messageCategory implementorsCount sendersCount packages library changeSets properties) )	
		#(syntaxHighlightingAsYouType true )
		#(showAssignmentAsLeftArrow false )
		#(replaceUnicodeArrowsWithSmalltalkArrows true)
		#(useWideMinusAndCenteredAsteriskGlyphs true )
		#(clearPackagePathsOnImageMove true)
	)! !


!Utilities class methodsFor: 'identification' stamp: 'jmv 26/Aug/2026, 2:39:36 pm (UTC)'!
methodsWithInitials: targetInitials
	"Based on a do-it contributed to the Squeak mailing list by Göran Hultgen:
- Browse methods whose initials (in the time-stamp, as logged to disk) match the given initials.
- Print out the complete time-stamp table to the Transcript.
- Answer a list of (initials -> count) associations.

CAUTION: It may take several minutes for this to complete."

	"Time millisecondsToRun: [Utilities methodsWithInitials: 'bf'] 2031"

	| initials authorAndStamp  allSubmitters |
	initials := ''.
	authorAndStamp := ''.
	allSubmitters := Bag new.
	Smalltalk
		browseAllSelect:
			[:cm |
				authorAndStamp := cm authorAndStampAsSaved.
				initials := authorAndStamp isEmpty
					ifTrue:
						['']
					ifFalse:
						[authorAndStamp substrings first].
				initials := initials isEmpty
					ifTrue:
						['<no time stamp>']
					ifFalse:
						[initials first isDigit
							ifTrue:
								['<date>']
							ifFalse:
								[initials]].
				allSubmitters add: initials.
				(initials = targetInitials)]
		name: ('Methods with initials ', targetInitials)
		autoHighlight: nil.

	allSubmitters sortedCounts do: [:elem | Transcript newLine; show: elem asString].
	^ allSubmitters
! !


!SmalltalkCompleter class methodsFor: 'class initialization' stamp: 'jmv 26/Aug/2026, 2:39:48 pm (UTC)'!
initialize
	"
	It takes about 6 seconds, mostly because of the time to fetch method stamps from source files...
	[ SmalltalkCompleter initialize ]timeToRun
	Selectors inspect
	"
	| maxSortValue |
	
	EntriesLimit := 100.
	
	SmalltalkCompleter initializeNotifications.
	
	self protected: [
		Selectors := Trie new.
		"
		Smalltalk allBehaviorsDo: [:class |
			class selectorsAndMethodsDo: [ :sel :method |
				Selectors at: sel ifAbsentPut: [ 0 ].
				method messages do: [ :sentMsg |
					Selectors at: sentMsg put: (Selectors at: sentMsg ifAbsent: [ 0 ]) + 1 ]]].
		"
		Smalltalk allBehaviorsDo: [:class |
			class selectorsAndMethodsDo: [ :sel :method |
				self addSelector: sel method: method
					methodTimeStamp: method authorAndStampUTC updateSortingOfSentMessages: false ]].
		""
	
		"The following might not be found in #messages. Give them maximum priority."
		maxSortValue := SmallInteger maxVal.
		"From MessageNode>>#initialize"
		#(	ifTrue: ifFalse: ifTrue:ifFalse: ifFalse:ifTrue:
			and: or:
			whileFalse: whileTrue: whileFalse whileTrue
			to:do: to:by:do:
			caseOf: caseOf:otherwise:
			ifNil: ifNotNil:  ifNil:ifNotNil: ifNotNil:ifNil:) do: [ :sel |
				Selectors at: sel put: maxSortValue ].
	
		maxSortValue := SmallInteger maxVal-1.
		"From SystemDictionary >>#recreateSpecialObjectsArray"
		(1 to: Smalltalk specialSelectorSize) do:  [ :i | | sym |
			sym := Smalltalk specialSelectorAt: i.
			(Selectors includesKey: sym)
				ifTrue: [ Selectors at: sym put: maxSortValue ]]].! !

!methodRemoval: CodeProvider #timeStamp stamp: 'jmv 26/Aug/2026, 2:31:52 pm (UTC)'!
CodeProvider removeSelector: #timeStamp!
!methodRemoval: CompiledMethod #authorAndStamp stamp: 'jmv 26/Aug/2026, 2:39:53 pm (UTC)'!
CompiledMethod removeSelector: #authorAndStamp!
SmalltalkCompleter initialize!
