<?

// This is just an interface and shouldn't be called
class Filter
{
	function Match($obj) // pure virtual
	{
		return true; // an empty Filter matches everything
	}
}

class SimpleFilter extends Filter
{
	var $attrName;
	var $attrValue;
	
	function SimpleFilter($attrName, $attrValue)
	{
		print ("<!-- attrName=$attrName, attrValue=$attrValue -->\n");
		$this->attrName = $attrName;
		$this->attrValue = $attrValue;
	}
	
	function Match($obj)
	{
		$atName = $this->attrName;
		return ($obj->$atName == $this->attrValue);
	}
}

class AndFilter extends Filter
{
	var $f1;
	var $f2;
	
	function AndFilter($f1, $f2)
	{
		$this->f1 = $f1;
		$this->f2 = $f2;
	}
	
	function Match($obj)
	{
		return ($this->f1->Match($obj) && $this->f2->Match($obj));
	}
}

class OrFilter extends Filter
{
	var $f1;
	var $f2;
	
	function OrFilter($f1, $f2)
	{
		$this->f1 = $f1;
		$this->f2 = $f2;
	}
	
	function Match($obj)
	{
		return ($this->f1->Match($obj) || $this->f2->Match($obj));
	}
}

class NotFilter extends Filter
{
	var $f1;
	
	function NotFilter($f1)
	{
		$this->f1 = $f1;
	}
	
	function Match($obj)
	{
		return (!($f1->Match($obj)));
	}
}

?>