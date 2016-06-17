package patternLayer;

//@Service(interfaces={QueryService.class, PersistenceService.class})
public class Data implements QueryService, PersistenceService{
	
	public Data(){
		super();
	}
	
	public Object executeQuery(Object query){
		/*
		 * insert code to query data
		 */
		return "";
	}
	
	public boolean updateData(Object update){
		/*
		 * insert code to update data
		 */
		return true;
	}
}
