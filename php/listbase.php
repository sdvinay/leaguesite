<?

// Generic list class, used to encapsulate a list
// Derive off of this to make more complex lists
//   (i.e., read in from file, from database, etc.)
// Owns a real array
// Implements  the standard iterator functions as methods
class ListBase
{
	var $myArray = array();
	
	function current()	{ return current($this->myArray); }
	function each()		{ return each($this->myArray); }
	function next()		{ return next($this->myArray); }
	function prev()		{ return prev($this->myArray); }
	function end()		{ return end($this->myArray); }
	function each()		{ return each($this->myArray); }
	function key()		{ return key($this->myArray); }
	
	function Count()	{ return count($this->myArray); }
}

?>