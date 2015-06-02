/*
 * Copyright 2015 Workiva Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

 part of r_tree;

class NonLeafNode extends Node {
  List<Node> _childNodes = [];
  List<Node> get children => _childNodes;

  NonLeafNode(int branchFactor) 
    : super(branchFactor);

  Node createNewNode() {
    return new NonLeafNode(branchFactor);
  }

  Iterable<RTreeDatum> search(Rectangle searchRect) {
    List<RTreeDatum> overlappingLeafs = [];
    
    _childNodes.forEach((Node childNode) {
      if (childNode.overlaps(searchRect)) {
        overlappingLeafs.addAll(childNode.search(searchRect));
      }
    });
    
    return overlappingLeafs;
  }

  Node insert(RTreeDatum item) {
    include(item);
    
    Node bestNode = _getBestNodeForInsert(item);
    Node splitNode = bestNode.insert(item);

    if (splitNode != null) {
      addChild(splitNode);
    }

    return splitIfNecessary();
  }

  remove(RTreeDatum item) {
    List<Node> childrenToRemove = [];
    
    _childNodes.forEach((Node childNode) {
      if (childNode.overlaps(item.rect)) {
        childNode.remove(item);
        
        if (childNode.size == 0) {
          childrenToRemove.add(childNode);
        }
      }
    });
    
    childrenToRemove.forEach((Node child) {
      removeChild(child);
    });
  }
  
  addChild(Node child) {
    super.addChild(child);
    child.parent = this;
  }

  removeChild(Node child) {
    super.removeChild(child);
    child.parent = null;
  }

  clearChildren() {
    _childNodes = [];
    _minimumBoundingRect = null;
  }

  Node _getBestNodeForInsert(RTreeDatum item) {
    num bestCost = double.INFINITY;
    num tentativeCost;
    Node bestNode;
    
    _childNodes.forEach((Node child) {
      tentativeCost = child.expansionCost(item);
      if (tentativeCost < bestCost) {
        bestCost = tentativeCost;
        bestNode = child;
      }
    });
    
    return bestNode;
  }
}