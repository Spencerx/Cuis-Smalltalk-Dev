'From Cuis7.1 [latest update: #6550] on 30 July 2024 at 9:33:16 am'!

!InnerTextMorph methodsFor: 'accessing' stamp: 'jmv 7/30/2024 09:28:36'!
textProviderOrModel

	^ (model is: #hasTextProvider) ifTrue: [ model textProvider ] ifFalse: [ model ].! !

