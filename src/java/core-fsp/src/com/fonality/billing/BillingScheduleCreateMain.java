package com.fonality.billing;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.apache.log4j.Logger;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

import com.fonality.billing.DTO.ServerBillingCycleDTO;
import com.fonality.billing.service.BillingScheduleCreateService;
import com.fonality.billing.service.BillingTransactionService;
import com.fonality.bu.entity.UnboundCdrTest;
import com.fonality.util.DateUtils;

public class BillingScheduleCreateMain {
	
	
	private static final Logger LOGGER = Logger.getLogger(BillingScheduleCreateMain.class.getName());
	protected static ApplicationContext context;
	
    public BillingScheduleCreateMain() {
    	setContext();
    }
	
   
    
    
	public static void main (String [] args) {
				
		try {
			
			BillingScheduleCreateMain bm = new BillingScheduleCreateMain();
			
			BillingScheduleCreateService billingScheduleCreateService = 
					(BillingScheduleCreateService) context.getBean("billingScheduleCreateService"); 
			
			// Billing Cycle date range.
			Date startDate = DateUtils.formatDate("09/21/12", DateUtils.USA_DATETIME);
			Date endDate = DateUtils.formatDate("10/21/12", DateUtils.USA_DATETIME);
		
			List<ServerBillingCycleDTO> serverBCList = getServerBillingCycleList ();
			
			billingScheduleCreateService.createScheduleForAllServers(serverBCList);
			//billingScheduleCreateService.createScheduleForNewServers(startDate, endDate);
			
			
			
		}
		catch (Exception e) {
			LOGGER.error("Main - Exception: ", e);
		}
		
	}
	
	
	public void setContext() {
		context = new ClassPathXmlApplicationContext( "classpath:application-context.xml");
	}
	
	
	private static List<ServerBillingCycleDTO> getServerBillingCycleList () {
		
		List<ServerBillingCycleDTO> serverList = new ArrayList<ServerBillingCycleDTO> ();
/* 1
		serverList.add(new ServerBillingCycleDTO(19075,"09/14/12","10/14/12"));
		serverList.add(new ServerBillingCycleDTO(18836,"09/21/12","10/21/12"));
		serverList.add(new ServerBillingCycleDTO(12266,"08/28/12","09/28/12"));
		serverList.add(new ServerBillingCycleDTO(18749,"10/21/12","11/21/12"));
		serverList.add(new ServerBillingCycleDTO(18581,"10/20/12","12/20/12"));
		
		serverList.add(new ServerBillingCycleDTO(18481,"11/20/12","12/20/12"));
		serverList.add(new ServerBillingCycleDTO(16110,"11/23/12","12/23/12"));
		serverList.add(new ServerBillingCycleDTO(17267,"01/09/13","02/09/13"));
		serverList.add(new ServerBillingCycleDTO(11145,"09/25/12","10/25/12"));
		serverList.add(new ServerBillingCycleDTO(18368,"12/23/12","01/23/12"));
	2
		serverList.add(new ServerBillingCycleDTO(19788,"11/21/12","12/21/12"));
		serverList.add(new ServerBillingCycleDTO(19129,"11/21/12","12/21/12"));
		serverList.add(new ServerBillingCycleDTO(12798,"12/28/12","01/28/13"));
		serverList.add(new ServerBillingCycleDTO(11694,"09/25/12","10/25/12"));
		serverList.add(new ServerBillingCycleDTO(14917,"10/15/12","11/15/12"));
		
		serverList.add(new ServerBillingCycleDTO(19171,"09/26/12","10/26/12"));
		serverList.add(new ServerBillingCycleDTO(19756,"09/16/12","10/16/12"));
		serverList.add(new ServerBillingCycleDTO(15391,"02/11/13","03/11/13"));
		serverList.add(new ServerBillingCycleDTO(18353,"09/21/12","10/21/12"));
		serverList.add(new ServerBillingCycleDTO(17145,"09/30/12","10/30/12"));
	3
		serverList.add(new ServerBillingCycleDTO(14635,"08/25/12","09/25/12"));
		serverList.add(new ServerBillingCycleDTO(16767,"09/21/12","10/21/12"));
		serverList.add(new ServerBillingCycleDTO(18127,"09/24/12","10/24/12"));
		serverList.add(new ServerBillingCycleDTO(14621,"12/22/12","01/22/13"));
		serverList.add(new ServerBillingCycleDTO(16577,"10/05/12","11/05/12"));
		
		serverList.add(new ServerBillingCycleDTO(18680,"09/25/12","10/25/12"));
		serverList.add(new ServerBillingCycleDTO(18603,"11/28/12","11/28/12"));
		serverList.add(new ServerBillingCycleDTO(14676,"10/21/12","11/21/12"));
		serverList.add(new ServerBillingCycleDTO(18618,"09/21/12","10/21/12"));
		serverList.add(new ServerBillingCycleDTO(11902,"06/04/12","07/04/12"));
	4
		serverList.add(new ServerBillingCycleDTO(10839,"09/22/12","10/22/12"));
		serverList.add(new ServerBillingCycleDTO(16292,"08/21/12","09/21/12"));
		serverList.add(new ServerBillingCycleDTO(14820,"08/27/12","09/27/12"));
		serverList.add(new ServerBillingCycleDTO(16862,"09/30/12","10/30/12"));
		serverList.add(new ServerBillingCycleDTO(14701,"10/15/12","11/15/12"));
		
		serverList.add(new ServerBillingCycleDTO(15366,"09/28/12","10/28/12"));
		serverList.add(new ServerBillingCycleDTO(18328,"08/30/12","09/30/12"));
		serverList.add(new ServerBillingCycleDTO(12493,"06/29/12","07/29/12"));
		serverList.add(new ServerBillingCycleDTO(19608,"09/18/12","10/18/12"));
		serverList.add(new ServerBillingCycleDTO(17217,"09/05/12","10/05/12"));
	5	
		serverList.add(new ServerBillingCycleDTO(19918,"11/22/12","12/22/12"));
		serverList.add(new ServerBillingCycleDTO(13167,"09/27/12","10/27/12"));
		serverList.add(new ServerBillingCycleDTO(17513,"10/15/12","11/15/12"));
		serverList.add(new ServerBillingCycleDTO(17761,"10/17/12","11/17/12"));
		serverList.add(new ServerBillingCycleDTO(18383,"11/01/12","12/01/12"));
		
		serverList.add(new ServerBillingCycleDTO(16517,"09/22/12","10/22/12"));
		serverList.add(new ServerBillingCycleDTO(20151,"11/24/12","12/24/12"));
		serverList.add(new ServerBillingCycleDTO(14994,"10/02/12","11/02/12"));
		serverList.add(new ServerBillingCycleDTO(17705,"05/07/12","06/07/12"));
		serverList.add(new ServerBillingCycleDTO(17362,"09/19/12","10/19/12"));
	6
		serverList.add(new ServerBillingCycleDTO(20122,"11/21/12","12/21/12"));
		serverList.add(new ServerBillingCycleDTO(16695, "09/21/12","10/21/12"));
		serverList.add(new ServerBillingCycleDTO(15307, "08/21/12","09/22/12"));
		serverList.add(new ServerBillingCycleDTO(19529, "09/09/12","10/09/12"));
		serverList.add(new ServerBillingCycleDTO(19633, "12/21/12","01/21/13"));
		
		serverList.add(new ServerBillingCycleDTO(18229, "10/07/12","11/07/12"));
		serverList.add(new ServerBillingCycleDTO(13411, "09/11/12","10/11/12"));
		serverList.add(new ServerBillingCycleDTO(18387, "09/24/12","10/24/12"));
		serverList.add(new ServerBillingCycleDTO(19160, "11/23/12","12/23/12"));
		serverList.add(new ServerBillingCycleDTO(16038, "09/21/12","10/21/12"));
	7				
		serverList.add(new ServerBillingCycleDTO(14785, "08/19/12","09/19/12"));
		serverList.add(new ServerBillingCycleDTO(16505, "11/21/12","12/21/12"));
		serverList.add(new ServerBillingCycleDTO(12701, "06/07/12","07/07/12"));
		serverList.add(new ServerBillingCycleDTO(15674, "09/21/12","10/21/12"));
		serverList.add(new ServerBillingCycleDTO(13836, "08/28/12","08/28/12"));
		
		serverList.add(new ServerBillingCycleDTO(10597, "05/19/12","06/19/12"));
		serverList.add(new ServerBillingCycleDTO(16417, "09/22/12","10/22/12"));
		serverList.add(new ServerBillingCycleDTO(17786, "09/14/12","10/14/12"));
		serverList.add(new ServerBillingCycleDTO(12863, "10/14/12","11/14/12"));
		serverList.add(new ServerBillingCycleDTO(13895, "10/15/12","11/15/12"));
	8		
		serverList.add(new ServerBillingCycleDTO(19184, "09/21/12","10/21/12"));
		serverList.add(new ServerBillingCycleDTO(18723, "10/10/12","11/10/12"));
		serverList.add(new ServerBillingCycleDTO(15310, "09/28/12","10/28/12"));
		serverList.add(new ServerBillingCycleDTO(18370, "09/11/12","10/11/12"));
		serverList.add(new ServerBillingCycleDTO(11418, "10/15/12","11/15/12"));
		
		serverList.add(new ServerBillingCycleDTO(14309, "09/24/12","10/24/12"));
		serverList.add(new ServerBillingCycleDTO(16773, "10/23/12","11/23/12"));
		serverList.add(new ServerBillingCycleDTO(10645, "10/04/12","11/04/12"));
		serverList.add(new ServerBillingCycleDTO(14644, "09/25/12","10/25/12"));
		serverList.add(new ServerBillingCycleDTO(13372, "11/15/12","12/15/12"));
	9		
		serverList.add(new ServerBillingCycleDTO(12580, "12/21/12","01/21/13"));
		serverList.add(new ServerBillingCycleDTO(16289, "10/28/12","11/28/12"));
		serverList.add(new ServerBillingCycleDTO(13662, "09/25/12","10/25/12"));
		serverList.add(new ServerBillingCycleDTO(20357, "12/28/12","01/28/13"));
		serverList.add(new ServerBillingCycleDTO(18847, "09/18/12","10/18/12"));
		
		serverList.add(new ServerBillingCycleDTO(18600, "05/13/12","06/13/12"));
		serverList.add(new ServerBillingCycleDTO(15995, "08/28/12","09/28/12"));
		serverList.add(new ServerBillingCycleDTO(18274, "11/28/12","12/28/12"));
		serverList.add(new ServerBillingCycleDTO(14173, "11/27/12","12/27/12"));
		serverList.add(new ServerBillingCycleDTO(18506, "12/21/12","01/21/12"));	
	10
			
		serverList.add(new ServerBillingCycleDTO(19130, "10/21/12","11/21/12"));
		serverList.add(new ServerBillingCycleDTO(19550, "09/10/12","10/10/12"));
		serverList.add(new ServerBillingCycleDTO(15197, "09/28/12","10/28/12"));
		serverList.add(new ServerBillingCycleDTO(18770, "10/11/12","11/11/12"));
		serverList.add(new ServerBillingCycleDTO(14868, "09/27/12","10/27/12"));
		
		serverList.add(new ServerBillingCycleDTO(10716, "11/13/12","12/13/12"));
		serverList.add(new ServerBillingCycleDTO(19112, "09/24/12","10/09/12"));
		serverList.add(new ServerBillingCycleDTO(11141, "04/24/12","05/24/12"));
		serverList.add(new ServerBillingCycleDTO(15095, "11/07/12","12/07/12"));
		serverList.add(new ServerBillingCycleDTO(19139, "10/21/12","11/21/12"));
		
		serverList.add(new ServerBillingCycleDTO(12607, "06/02/12","07/02/12"));
		serverList.add(new ServerBillingCycleDTO(14377, "11/25/12","12/25/12"));
		serverList.add(new ServerBillingCycleDTO(15415, "09/28/12","10/28/12"));
		serverList.add(new ServerBillingCycleDTO(17073, "09/25/12","10/25/12"));
		serverList.add(new ServerBillingCycleDTO(17589, "09/21/12","10/21/12"));
	*/	
		return serverList;
	}
	

}
