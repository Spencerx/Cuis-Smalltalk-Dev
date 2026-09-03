'From Cuis7.9 [latest update: #8147] on 24 August 2026 at 6:32:05 pm'!

!ExtractMethodApplier methodsFor: 'refactoring - parameters request' stamp: 'JEC 24/Aug/2026, 9:31:38 pm (UTC)'!
requestNewMessageWithAllParameterizedValues

	| parseNodesToParameterized renameMeArguments |

	self initializeNewMessageArguments.
	
	parseNodesToParameterized := self parseAndParameterizableNodesToParameterizeInOrder.
	
	renameMeArguments := parseNodesToParameterized withIndexCollect: [ :node :index | 
		(node isVariableNode and: [ node isInstanceVariableNode not ])
			ifTrue: [ node ]
			ifFalse: [ VariableNode named: 'aRenameMe' , index asString ] ].

	^ self 
		requestNewMessageFor: parseNodesToParameterized 
		usingForSaving: renameMeArguments.! !

