'From Cuis7.9 [latest update: #8120] on 18 August 2026 at 9:11:06 pm'!

!TheWorldMenu class methodsFor: 'as yet unclassified' stamp: 'hlsf 18/Aug/2026, 7:07:41 pm (UTC)'!
quit
	Smalltalk askConfirmationOnQuit ifFalse: [ ^ self ].
	Smalltalk quit! !


!WorldMorph methodsFor: 'events' stamp: 'hlsf 18/Aug/2026, 7:08:00 pm (UTC)'!
windowEvent: aWindowEvent

	aWindowEvent windowEventType == #windowClose
		ifTrue: [^(Preferences at: #worldMenu) quit]
! !


!TheWorldMenu methodsFor: 'commands' stamp: 'hlsf 18/Aug/2026, 7:07:49 pm (UTC)'!
quitSession
	self class quit! !

