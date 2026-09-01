'From Cuis7.9 [latest update: #8149] on 1 September 2026 at 12:51:52 pm'!
!classDefinition: #WorldMorph category: #'Morphic-Kernel'!
PasteUpMorph subclass: #WorldMorph
	instanceVariableNames: 'activeHand canvas damageRecorder stepList lastCycleTime alarms lastAlarmTime deferredUIMessages drawingFailingMorphs waitDelay pause lastCycleHadAnyEvent taskbar averagedMSperCycle '
	classVariableNames: 'ScaleFactor '
	poolDictionaries: ''
	category: 'Morphic-Kernel'!

!WorldMorph methodsFor: 'accessing' stamp: 'jmv 31/Aug/2026, 3:17:00 pm (UTC)'!
averagedMSperCycle
	"
	self runningWorld averagedMSperCycle
	"
	^averagedMSperCycle! !

!WorldMorph methodsFor: 'accessing' stamp: 'jmv 31/Aug/2026, 4:48:51 pm (UTC)'!
requestedCyclePause
	^pause! !


!TaskbarMorph methodsFor: 'accessing' stamp: 'jmv 1/Sep/2026, 3:50:31 pm (UTC)'!
clockString
	| w ms |
	w := self world.
	^String streamContents: [ :strm |
		strm nextPutAll: '  '.
		DateAndTime now printHMSOn: strm.
		showFPS ifTrue: [
			strm nextPutAll: ' FPS: '.
			ms := w averagedMSperCycle.
			ms > 1
				ifTrue: [(1000.0 / ms) printOn: strm fractionDigits: 1 ]
				ifFalse: [ strm nextPutAll: '>500' ].
			strm nextPutAll: ' (pause: '.
			(w requestedCyclePause) printOn: strm "fractionDigits: 1".
			strm nextPutAll: ' mS)'. ].
		strm nextPutAll: ' ' ].! !

!TaskbarMorph methodsFor: 'accessing' stamp: 'jmv 31/Aug/2026, 3:17:57 pm (UTC)'!
hideFPS
	showFPS := false.
	clock stepTime: 1000. "1 second resolution"
	clock step; morphExtent: `0@0`.! !

!TaskbarMorph methodsFor: 'accessing' stamp: 'jmv 31/Aug/2026, 3:18:10 pm (UTC)'!
showFPS
	 showFPS := true.
	clock stepTime: 500. "Better appreciate fps changes."! !


!WorldMorph methodsFor: 'update cycle' stamp: 'jmv 31/Aug/2026, 4:47:29 pm (UTC)'!
doOneCycleNowOn: aMorphicCanvas
	"Immediately do one cycle of the interaction loop.
	Only used for a few tests."
	"See #eventTickler"
	| thisCycleTime timeDelta k hadAny |
	thisCycleTime := Time localMillisecondClock.
	timeDelta := thisCycleTime - lastCycleTime.
	"Tau = 1000ms, chosen arbitrarily(https://en.wikipedia.org/wiki/Time_constant)"
	k := 0.632 * timeDelta / 1000.0 min: 1.0 max: 0.001.
	"{timeDelta. k} print."
	averagedMSperCycle := averagedMSperCycle
		ifNil: [ timeDelta]
		ifNotNil: [ (averagedMSperCycle * (1.0-k)) + (timeDelta * k) ].
	Cursor currentCursor = (Cursor cursorAt: #waitCursor) ifTrue: [ Cursor defaultCursor activateCursor ].
	"Repair visual damage."
	self checkForNewScreenSize.
	self displayWorldOn: aMorphicCanvas.
	"Run steps, alarms and deferred UI messages."
	self runDeferredUIMessages.
	self triggerAlarmsBefore: thisCycleTime.
	self runLocalStepMethods: thisCycleTime.
	"Ensure that any affected morph is redrawn ASAP."
	self displayWorldOn: aMorphicCanvas.
	"Process user input events. Run all event triggered code."
	hadAny := activeHand processEventQueue.
	"Run any deferred UI messages that were enqueued during this cycle, perhaps
	as consequence of event handling or step methods, or sent from other processes,
	before the inter cycle pause."
	self runDeferredUIMessages.
	"Ensure that any affected morph is redrawn ASAP, before the inter cycle pause."
	self displayWorldOn: aMorphicCanvas.
	lastCycleTime := thisCycleTime.
	lastCycleHadAnyEvent := hadAny.! !

!classDefinition: #WorldMorph category: #'Morphic-Kernel'!
PasteUpMorph subclass: #WorldMorph
	instanceVariableNames: 'activeHand canvas damageRecorder stepList lastCycleTime alarms lastAlarmTime deferredUIMessages drawingFailingMorphs waitDelay pause lastCycleHadAnyEvent taskbar averagedMSperCycle'
	classVariableNames: 'ScaleFactor'
	poolDictionaries: ''
	category: 'Morphic-Kernel'!
