<?

// profiler.php
// $Revision$
// $Date$

// Class used for profiling; it uses a timer to track
// the elapsed times for various phases of execution

// Implementation:
	// one timer runs for the lifetime of each instance
	// each Profiler is always in a "phase"
	// the phases (and their names) are defined by client
	// Profiler has a table with the start time of each phase

require_once("timer.php");
require_once("listbase.php");

class Profiler extends ListBase
{
	var $timer;
	 
	function Profiler($phase_name = "profiler_start")
	{
		$this->myArray = array();
		$this->timer = new Timer();
		$this->Phase($phase_name);
	}
	
	// We don't currently check that $phase_name is unique;
	// behavior is wacky if it is a duplicate
	function Phase($phase_name)
	{
		$this->myArray[$phase_name] = $this->timer->GetElapsedTime();
	}
	
	// This prints out the phase times in an HTML table
	// Assumes we're done profiling at this point; if not, client
	// should call this with false (and create a new phase for this
	// call)
	function PrintTimesHTML($stop = true)
	{
		if ($stop)
			$this->timer->Stop();
		print("<table><tr><th>Phase Name</th><th>Start Time</th><th>Phase Time</th></tr>\n");
		list($last_phase, $last_time) = $this->each();
		while (list($phase_name, $timestamp) = $this->each())
		{
			printf("<tr><td>%s</td><td>%.3f</td><td>%.3f</td></tr>\n",
				$last_phase, $last_time, $timestamp-$last_time);
			$last_phase = $phase_name;
			$last_time = $timestamp;
		}
		printf("<tr><td>%s</td><td>%.3f</td><td>%.3f</td></tr>\n",
			$last_phase, $last_time, $this->timer->GetElapsedTime()-$last_time);
		print("</table>\n");
	}
	
}

?>