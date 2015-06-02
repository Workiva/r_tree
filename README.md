#RTree [![Build Status](https://travis-ci.org/Workiva/r_tree.svg)](https://travis-ci.org/Workiva/r_tree)

A recursive RTree library written in Dart.

"R-trees are tree data structures used for spatial access methods, i.e., for indexing multi-dimensional information such as geographical coordinates, rectangles or polygons." - http://en.wikipedia.org/wiki/R-tree

##API

-  *RTree* ( [ Number **branch_factor** ] )

###Parameters: 

-  **branch_factor** : _optional_ : The maximum width of a node before a split is performed[<sup>1</sup>](#f1).

###Returns: 

-  An empty **RTree** object.



##RTree.insert

-  **insert** ( RTreeDatum[<sup>2</sup>](#f2) **item** )

###Parameters: 

-  **item** : **required** : An item to insert into the tree.



##RTree.remove

-  **remove** ( RTreeDatum[<sup>2</sup>](#f2) **item** )

###Parameters: 

- **item** : **required** : An item to remove from the RTree.



##RTree.search

-  **search** ( Rectangle **area** )

###Parameters: 

-  **area** : **required** : An area to search within.

###Returns: 

-  An Iterable\<RTreeDatum\<E\>\> of objects that overlap **area**.
-  *Note:* Rectangles that simply share a border are not considered to overlap.


###Notes

<sup><a name="f1">1</a></sup> Default max node width is currently 16.

<sup><a name="f2">2</a></sup> RTreeDatum is simply a way to bind a Rectangle to an Object.
