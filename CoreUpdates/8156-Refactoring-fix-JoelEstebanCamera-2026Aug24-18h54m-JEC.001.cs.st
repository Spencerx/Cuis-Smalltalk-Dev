'From Cuis7.9 [latest update: #8147] on 24 August 2026 at 7:06:24 pm'!

!ExtractMethodTempVarCodeModifier methodsFor: 'testing' stamp: 'JEC 24/Aug/2026, 9:57:25 pm (UTC)'!
isUsedAsAnArgument

	^ newMessage notNil and: [ newMessage hasArgument: extractedNode name ]! !

