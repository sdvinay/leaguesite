<?

// $Revision$
// $Date$

// FileWriter class 
// encapsulates a file that is open for writing
// provides some common utility functions

class FileWriter
{
	var $fd;
	
	function FileWriter($filepath)
	{
		$this->fd = fopen($filepath, "w");
		flock($this->fd, LOCK_EX);
	}
	
	function Write($str)
	{
		return fwrite($this->fd, $str);
	}
	
	function WriteLine($str)
	{
		$this->Write($str);
		return $this->EndLine();
	}
	
	function EndLine()
	{
		return $this->Write("\n");
	}
	
	function Close()
	{
		flock($this->fd, LOCK_UN);
		return fclose($this->fd);
	}
}

?>