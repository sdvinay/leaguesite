<?

// $Revision$
// $Date$

// This is just an interface and shouldn't be called
class Filter
{
	function Match($obj) // virtual
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
		$this->attrName = $attrName;
		$this->attrValue = $attrValue;
	}
	
	function Match($obj)
	{
		$atName = $this->attrName;
		return ($obj->$atName == $this->attrValue);
	}
}

// This is a pure virtual class
// The method ReduceFunc(bool, bool) needs to be implemented
// ReduceFunc() is the actual composition method
// Construct a CompositionFilter with an array of filters
// Match() will iterate over the filters, calling Match()
//  on each filter, and composing the results with ReduceFunc()
class CompositionFilter extends Filter
{
	var $filterArray = array();
	
	function CompositionFilter($array)
	{
		$this->filterArray =& $array; 
	}
	
	function Reduce($runningTotal, $filter, $obj)
	{
		return $this->ReduceFunc($runningTotal, $filter->Match($obj));
	}
	
	function Match($obj)
	{
		reset($this->filterArray);
		$filter = current($this->filterArray);
		$match = $filter ? $filter->Match($obj) : true; // if there are no filters, just return true
		while ($filter = next($this->filterArray))
		{
			$match = $this->Reduce($match, $filter, $obj);
		}
		return $match; 
	}
}

class AndFilter extends CompositionFilter
{
	function AndFilter($array)
	{
		parent::CompositionFilter($array);
	}

	function ReduceFunc($v1, $v2)
	{	return ($v1 && $v2);	}
	
}

class OrFilter extends CompositionFilter
{
	function ReduceFunc($v1, $v2)
	{	return ($v1 || $v2);	}
	
	function OrFilter($array)
	{
		parent::CompositionFilter($array);
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