<?

// $Revision$
// $Date$

// FileReader class 
// encapsulates a file that is open for writing
// provides some common utility functions, handles locking

class FileReader
{
	var $fd;
	
	function FileReader($filepath)
	{
		$this->fd = fopen($filepath, "r");
		flock($this->fd, LOCK_SH);
	}
	
	function Close()
	{
		flock($this->fd, LOCK_UN);
		return fclose($this->fd);
	}
	
	function GetLine()
	{
		return fgets($this->fd, 1024);
	}

	function Read($length)
	{
		return read($this->fd, $length);
	}
}

?>