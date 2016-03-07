//@Remotable
module RequestResponseService
import STDL/StandardLibrary
import STDL/CommonBehavior
export *
signature:
domain RequestResponseService subsetof Agent
out request: Prod(Agent,D) -> Rule
module ClientRequestResponseComponent
import STDL/StandardLibrary
import STDL/CommonBehavior
//@Required service
import RequestResponseService
export *
signature:
//@Reference
shared fRequestResponse : Agent -> RequestResponseService
controlled items: Agent -> D
controlled result: Agent -> D
definitions:
rule r_ClientRequestResponseComponent =
//Make the request in a synchronous manner by send-receive
r_wsendreceive[fRequestResponse(self),"r_request(Agent,D)",items(self),result(self)]
rule r_init($a in ClientRequestResponseComponent) =
//Complete this rule body for the startup of the component
status($a) := READY
module ServerComponent
import STDL/StandardLibrary
import STDL/CommonBehavior
//@MainService
import RequestResponseService
export *
signature:
//@Backref to the client agent
shared client : Agent -> Agent
controlled params: Agent -> D
controlled response: Agent -> D
definitions:
//@Service
rule r_request($a in Agent,$params in D)=
skip //Refine this rule body by replacing skip with with your ASM rule scheme
rule r_ServerComponent =
let($r = nextRequest(self)) //Select the next request (if any)
in if isDef($r) then
seq //Handle the request $r
r_wreceive[client(self),"r_request(Agent,D)",params(self)]
if (isDef(params(self))) then r_request[self,params(self)] endif
r_wreply(client(self),"r_request(Agent,D)",response(self))
endseq
rule r_init($a in RequestResponseService) =
//Complete this rule body for the startup of the component
status($a) := READY