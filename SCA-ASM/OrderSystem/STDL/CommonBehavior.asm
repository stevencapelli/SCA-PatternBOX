module CommonBehavior
import StandardLibrary
export *
		
signature:

	anydomain AnyD
	dynamic abstract domain Message
	domain CommunicationChannel subsetof Agent
	domain Clock subsetof Agent
	enum domain Status = {INIT |  READY | BLOCKED | EXITED | EXCEPTION | COMPENSATION } 
	enum domain CommunicatorStatus = { AVAILABLE | UNAVAILABLE  | RESET} 
		
	dynamic controlled recipient : Message -> Agent 
	dynamic controlled sender : Message -> Agent
	dynamic controlled serviceOp : Message -> String // Rule(Any) ??
	dynamic controlled serviceData : Message -> Any
	
	dynamic controlled responseMsg : Message -> Message
	dynamic controlled isResponseMsg : Message -> Boolean
	dynamic controlled isRequestMsg : Message -> Boolean
	dynamic controlled requestMsg : Message -> Message
	dynamic controlled waitingFor : Prod(Agent,Message) -> Boolean
	dynamic controlled received : Message -> Boolean
	dynamic controlled timestamp : Message -> Integer
	dynamic controlled status : Agent -> Status
	dynamic shared communicatorStatus : CommunicationChannel -> CommunicatorStatus
	 
	
	dynamic controlled inbox : Agent -> Seq(Message)
	dynamic controlled outbox : Agent -> Seq(Message)
	dynamic controlled mailbox : Agent -> Seq(Message)
	dynamic controlled sendMode : Message -> Boolean
	dynamic controlled readyToReceive : Message -> Boolean
	derived arriving : Message -> Boolean
	derived okSend : Message -> Boolean
	derived sendFaultMode : Message -> Boolean
	
	//dato un agente ed un messaggio restituisce l'handler per gestire la compensazione
	dynamic controlled compensationHandler : Prod(Agent,String) -> Rule(Agent)
	
	//dato un agente ed una stringa (che indica una attività) restituisce le azioni
	// che sono state eseguite e possono essere compensate
	dynamic controlled toCompensate: Prod(Agent,String) -> Seq(String) 
	
	//dato un agente ed un messaggio restituisce l'handler per gestire un'eccezione
	dynamic controlled exceptionHandler : Prod(Agent,String) -> Rule(Agent)
	 
	
	// serve per operare "scelte" da servire (da programma)
	dynamic controlled nextRequest : Agent -> Any
	
	dynamic controlled time : Clock -> Integer
	
	// segnaposto per eccezioni
	dynamic controlled exceptionSubject : Agent -> String

	
	static nextMsg : Prod(Seq(Message),Agent,String) -> Message
	
	static communicator : CommunicationChannel

	static clock : Clock
	
	
definitions:
	function okSend($m in Message) = // per ora verifico che non ci siano problemi sul canale
		not(communicatorStatus(communicator)=UNAVAILABLE)
	
	function sendFaultMode($m in Message) =
		sendMode($m) and not(okSend($m))
	
	function arriving ($m in Message) = contains(inbox(recipient($m)),$m)
	
	function nextMsg($queue in Seq(Message), $a in Agent, $s in String) =
		if isEmpty($queue) then undef
		else
			let ($first = first($queue)) in
				if (recipient($first)=self and sender($first)=$a and serviceOp($first)=$s) then $first
				else nextMsg(excluding($queue,$first),$a,$s)
				endif
			endlet		
		endif
	
		
	
	
rule r_msg_delivery = // il communicator prende i messaggi ancora da inviare e setta a true l''attributo inInbox.
	forall $msg in Message with contains(mailbox(communicator),$msg) do
		par
			inbox(recipient($msg)):=append(inbox(recipient($msg)),$msg)
			mailbox(communicator):=excluding(mailbox(communicator),$msg)
			if (isRequestMsg($msg)=true) then nextRequest(recipient($msg)):=serviceOp($msg) endif
		endpar
	


rule r_msg_fetching = // prendo i messaggi con attributo inOutbox=true e li metto nella mailbox del communicator
	forall $msg in Message with contains(outbox(sender($msg)),$msg) do
		seq
			outbox(sender($msg)):=excluding(outbox(sender($msg)),$msg)
			mailbox(communicator):=append(mailbox(communicator),$msg)
		endseq
		

rule r_check_channel =
	skip

rule r_basicsend($m in Message) = 
	seq
		outbox(sender($m)):=append(outbox(sender($m)),$m)
		sendMode($m):=false
	endseq


rule r_sendfaulthandler($m in Message) = skip

rule r_handlesendfault($m in Message) =
if sendFaultMode($m)=true then r_sendfaulthandler[$m] endif


rule r_firstsend($m in Message) =
if (sendMode($m) and okSend($m)) then 
	par
		r_basicsend[$m]
		waitingFor(self,$m):=true      // added for send-receive
	endpar
endif
	

rule r_send_noAck($m in Message) = 
	par
		r_firstsend[$m]
		r_handlesendfault[$m]
	endpar



rule r_wsend($lnk in Agent, $s in String, $snd in Any) = 
	if (isDef($snd) and status(self)=READY) then 
		extend Message with $m do
		seq
			par
				recipient($m):=$lnk
				sender($m):=self
				serviceOp($m):=$s
				serviceData($m):=$snd
				isRequestMsg($m):=true
				timestamp($m):=time(clock)
				sendMode($m):=true
			endpar
			r_send_noAck[$m]
		endseq
	endif

		
rule r_consume($m in Message, $rcv in Any) =
	par
		$rcv:=serviceData($m)
		status(recipient($m)):=READY
		inbox(recipient($m)):=excluding(inbox(recipient($m)),$m)
		
		if isDef(requestMsg($m)) then
			par
				waitingFor(sender(requestMsg($m)),requestMsg($m)):=false
				readyToReceive($m):=false
			endpar
		endif
	endpar


rule r_consume ($m in Message) =
	par
		status(recipient($m)):=READY
		inbox(recipient($m)):=excluding(inbox(recipient($m)),$m)
		if isDef(requestMsg($m)) then
			par
				waitingFor(sender(requestMsg($m)),requestMsg($m)):=false
				readyToReceive($m):=false
			endpar
		endif
	endpar

rule r_receive_noAckBlocking($m in Message, $rcv in Any) =
	if (arriving($m) and readyToReceive($m)) then
		r_consume[$m,$rcv]
	endif
		
	
rule r_receive_noAckBlocking($m in Message) =
	if (arriving($m) and readyToReceive($m)) then
		r_consume[$m]
	endif
	
	
rule r_wreceive($lnk in Agent, $s in String, $rcv in Any) =  
	if not isDef($rcv) then
		let ($m=nextMsg(inbox(self),$lnk,$s)) in
			if isDef($m) then
				seq
					readyToReceive($m):=true
					r_receive_noAckBlocking[$m,$rcv]
				endseq
			else
				status(self):=BLOCKED
			endif
		endlet
	endif	
			
rule r_wreceive($lnk in Agent, $s in String) =  
	let ($m=nextMsg(inbox(self),$lnk,$s)) in
		if isDef($m) then
			seq
				readyToReceive($m):=true
				r_receive_noAckBlocking[$m]
			endseq
		else
			status(self):=BLOCKED
		endif
	endlet
	
	
rule r_wreplay($lnk in Agent, $s in String, $snd in Any) =  
if (isDef($snd) and status(self)=READY) then
	choose $msg in Message with isRequestMsg($msg)=true and serviceOp($msg)=$s and recipient($msg)=self do
		extend Message with $m do
			seq
				
				par
					recipient($m):=$lnk
					sender($m):=self
					serviceOp($m):=$s
					serviceData($m):=$snd
					isResponseMsg($m):=true
					requestMsg($m):=$msg
					timestamp($m):=time(clock)
					sendMode($m):=true
				endpar
		
					responseMsg($msg):=$m
					isRequestMsg($msg):=false
					r_send_noAck[$m]
			endseq
	endif
			
	
	
rule r_sendreceive_noAck_noAckBlocking($m in Message, $s in String,  $rcv in Any) =
	seq
		r_send_noAck[$m]
		choose $mes in Message with recipient($mes)=self  and serviceOp($mes)=$s and isResponseMsg($mes)=true and requestMsg($mes)=$m
		do 
			seq
				readyToReceive($mes):=true
				r_receive_noAckBlocking[$mes,$rcv]
			endseq
		
	endseq
		
		
rule r_wsendreceive($lnk in Agent, $s in String, $snd in Any, $rcv in Any) =  
	if (isDef($snd) and not(isDef($rcv))) then
		choose $msg in Message with sender($msg)=self and waitingFor(self,$msg)=true and serviceOp($msg)=$s and recipient($msg)=$lnk do
			r_sendreceive_noAck_noAckBlocking[$msg,$s,$rcv]
		ifnone
		extend Message with $m do
			seq
				par
					recipient($m):= $lnk
					sender($m):= self
					serviceOp($m):= $s
					serviceData($m):= $snd
					isRequestMsg($m):= true
					timestamp($m):=time(clock)
					sendMode($m):= true
				endpar
				r_sendreceive_noAck_noAckBlocking[$m,$s,$rcv]
			endseq
	endif

rule r_wsendreceive($lnk in Agent, $s in String, $rcv in Any) =  
	if not(isDef($rcv)) then
		choose $msg in Message with sender($msg)=self and waitingFor(self,$msg)=true and serviceOp($msg)=$s and recipient($msg)=$lnk do
		r_sendreceive_noAck_noAckBlocking[$msg,$s,$rcv]
	ifnone
	extend Message with $m do
		seq
			par
				recipient($m):= $lnk
				sender($m):= self
				serviceOp($m):= $s
				isRequestMsg($m):= true
				timestamp($m):=time(clock)
				sendMode($m):= true
			endpar
			r_sendreceive_noAck_noAckBlocking[$m,$s,$rcv]
		endseq
	endif
		
rule r_init ($c in CommunicationChannel)= 
	par
		mailbox($c):=[]
		forall $a in Agent with not($a=communicator) do
			par
				inbox($a):=[]
				outbox($a):=[]
			endpar
		
	endpar
		
		
		
rule r_CommunicatorProgram =
	if (communicatorStatus (self) = RESET) 
	then  
	       par r_init [self] 
	            communicatorStatus(self) := AVAILABLE 
	       endpar
        else	if communicatorStatus(self)=AVAILABLE then
			par
				seq
					r_msg_fetching[]
					r_msg_delivery[]
				endseq
				r_check_channel[] 
			endpar
		endif
	endif


rule r_ClockProgram = 
if (status(self) = INIT) 
	then  
	       par
		     time(self):=0
	            status(self) := READY
	       endpar
        else	
		time(self):=time(self)+1
endif
   
rule r_raiseException($a in Agent, $exceptionHandler in String, $exceptionSubject in String) =
par
	status($a):=EXCEPTION
	exceptionHandler($a,$exceptionHandler)[$a]
	exceptionSubject($a):=$exceptionSubject
endpar

rule r_compensate($a in Agent, $compensationHandler in String) =
par
	status($a):=COMPENSATION
	compensationHandler($a,$compensationHandler)[$a]
endpar

rule r_compensateAll($a in Agent, $compensationHandlerList in String) =
while not(isEmpty(toCompensate($a,$compensationHandlerList))) do
	seq
		r_compensate[$a,first(toCompensate($a,$compensationHandlerList))]
		toCompensate($a,$compensationHandlerList):=excluding(toCompensate($a,$compensationHandlerList),last(toCompensate($a,$compensationHandlerList)))
	endseq

rule r_exit($a in Agent) =
	status($a):=EXITED   