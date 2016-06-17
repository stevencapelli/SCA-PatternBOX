package patternRouter;

//@Service(CustomerService.class)
public class Customer implements CustomerService {
  
	//@Reference
	protected RouterService routerService;
	public Customer(){
		super();
	}
	
	public void send(Object o){
		/*
		 * call RouteService
		 */
		routerService.routing(o);
	}
}
