<?

// timer.php
// $Revision$
// $Date$

// A simple timer class which uses the microtime() function
// to get high-precision times.  Designed for use in profiling

// Usage model:
	// instantiate (Start() is called by default during constructor)
	// call GetElapsedTime() as often as you want for "lap times"
	// Stop()
	// GetElapsedTime() for total time

class Timer
{
	var $state = 0;
	// 0 = not started yet
	// 1 = running
	// 2 = stopped
	
	var $start_time = 0;   // only set when $state>0
	var $end_time = 0;     // only set when $state>1
	var $elapsed_time = 0; // only set when $state>1
	 
	function Timer($start_now = true)
	{
		if ($start_now)
			$this->Start();
	}
	
	function Start()
	{
		if ($this->state !== 0)
			trigger_error();
		$this->state = 1;
		$this->start_time = $this->microtime();
	}
	
	function Stop()
	{
		if ($this->state !== 1)
			trigger_error();
		$this->end_time = $this->microtime();
		$this->state = 2;
		$this->elapsed_time = $this->end_time - $this->start_time;
	}
	
	function GetElapsedTime()
	{
		switch($this->state)
		{
			case 1:
				return ($this->microtime() - $this->start_time);
			case 2:
				return $this->elapsed_time;
			default:
				trigger_error();
				return;
		}
	}
	
	function microtime()
	{
		return array_sum(explode(' ', microtime()));
	}
}

?>