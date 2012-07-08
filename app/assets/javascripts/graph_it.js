
Date.prototype.add_days = function(n) {
    this.setDate(this.getDate()+n);
    return this;
};

function to_month_day(date) {   // convert time for rails format
    var curr_date = ('0' + (date.getDate() ) ).slice(-2); // pad with leading zero
    var curr_month = ('0' + (date.getMonth() + 1) ).slice(-2); //Months are zero based
    var curr_year = date.getFullYear();
    return (curr_year + "/" + curr_month + "/" + curr_date);
}

function fix_time(rails_time) {  // convert from rails format
	var date = rails_time.split("T")[0] ;
		var time = rails_time.split("T")[1].split("Z")[0] ;			 
		return date + " " + time ;
}		

function json_get_range() {		
		$.getJSON("/sites/data.json",
		null,
		function(RangeOfData){				  
			Records = RangeOfData[SiteID][1] ;
			First = fix_time(RangeOfData[SiteID][2]) ;
			Last = fix_time(RangeOfData[SiteID][3]) ;
			SpanOfTime = RangeOfData[SiteID][4] ;
			$('#records').html(Records);
			$('#first').html(First);
			$('#last').html(Last);	
			$('#spanoftime').html(SpanOfTime);
			json_get() ;			
		});
}

function json_get() {	
	StartDate = $('#plotstartdate').val()
	StopDate = $('#plotstopdate').val()	
	$.getJSON("/time_logs/data.json",
	{ site_id:SiteID,
	  start_date:StartDate,
	  stop_date:StopDate },
	function(json_raw){
		$('#plotspan').val(json_raw[1]);  // Number of data points in Range
		var Points = json_raw[1] ; 
		
		maxY = json_raw[2] ;   // Rails determined the maximum in data
  		var data = json_raw[0] ;  // first element in array is series data				
		series = [] ;

		for (i=0;i<=Points-1;i++)
		{ series.push ([0,0]) ;	}
		for (i=0;i<=Points-1;i++)
			{
				series[i][0] = fix_time(data[i].checked) ;
				series[i][1] = data[i].delay ;
			}
		show_get(series);
	});
}

function show_get(series) {	
			Number_of_ticks = $('#number_of_ticks').val() ;	    
			PlotStartDate = $('#plotstartdate').val() ;	    
			PlotStopDate = $('#plotstopdate').val() ;				    
			$.jqplot('chartdiv',  [series],
			{ title: SiteUrl + ' (Response Time)',
			  axes:{ yaxis: { min: 0, max: maxY },
			 		 xaxis: { renderer:$.jqplot.DateAxisRenderer,
				         tickOptions:{formatString:'%m/%d %H:%M'},
			  //     tickOptions:{formatString:'%m/%d/%y - %I:%M:%S'},
			         min: PlotStartDate ,
					 max: PlotStopDate ,
			 //		 numberTicks: Number_of_ticks ,
			 //      tickInterval: Tick_interval 
			           },
				   },
				grid: {
		            drawBorder: true, 
		            drawGridlines: true,
		            background: '#ffffff',
		            shadow:true
		        },
			  series:[{color:'#5FAB78'}]
			}
					).replot();													
}
	
function site_check() {
	 var id = document.getElementById('site_select').value ;
		$.getJSON("/sites/site_ids.json",
		null,
		function(sites_ids){
		var url = sites_ids[id] ;
		select_series(id,url) ;	  						
		});	     
}

function select_series(site_id, site_url) {
	SiteID = site_id ;		
	SiteUrl = site_url ;
	json_get_range() ;				
}
	
$(function() {
	$("#site_select").change(function() {	
	site_check() ;
	});	
			
});

$(function() {
	$( "#plotstartdate" ).datepicker({ dateFormat: "yy-mm-dd" });
	$( "#plotstopdate" ).datepicker({ dateFormat: "yy-mm-dd" });
});
