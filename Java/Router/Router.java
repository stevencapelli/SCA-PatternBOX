package patternRouter;

//@Service(RouterService.class)
public class Router implements RouterService{
  //@Reference
  protected Service1 service1;
  //@Reference
  protected Service2 service2;
  //@Reference
  protected Service3 service3;
  //@Protected
  protected String policy;
  
  public Router(){
	  super();
  }
  
  public void routing(Object o){
	  switch(policy){
	  case "service1":{
		  service1.executeService(o);
		  break;
	  }
	  case "service2":{
		  service2.executeService(o);
		  break;
	  }
	  case "service3":{
		  service3.executeService(o);
		  break;
	  }
	  default:
	  }
  }
  
  public String getPolicy(){
	  return this.policy;
  }
  
  public void setPolicy(String s){
	  this.policy=s;
  }
}