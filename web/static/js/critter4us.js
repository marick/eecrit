
(function() {
'use strict';

function F2(fun)
{
  function wrapper(a) { return function(b) { return fun(a,b); }; }
  wrapper.arity = 2;
  wrapper.func = fun;
  return wrapper;
}

function F3(fun)
{
  function wrapper(a) {
    return function(b) { return function(c) { return fun(a, b, c); }; };
  }
  wrapper.arity = 3;
  wrapper.func = fun;
  return wrapper;
}

function F4(fun)
{
  function wrapper(a) { return function(b) { return function(c) {
    return function(d) { return fun(a, b, c, d); }; }; };
  }
  wrapper.arity = 4;
  wrapper.func = fun;
  return wrapper;
}

function F5(fun)
{
  function wrapper(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return fun(a, b, c, d, e); }; }; }; };
  }
  wrapper.arity = 5;
  wrapper.func = fun;
  return wrapper;
}

function F6(fun)
{
  function wrapper(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return fun(a, b, c, d, e, f); }; }; }; }; };
  }
  wrapper.arity = 6;
  wrapper.func = fun;
  return wrapper;
}

function F7(fun)
{
  function wrapper(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return fun(a, b, c, d, e, f, g); }; }; }; }; }; };
  }
  wrapper.arity = 7;
  wrapper.func = fun;
  return wrapper;
}

function F8(fun)
{
  function wrapper(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) {
    return fun(a, b, c, d, e, f, g, h); }; }; }; }; }; }; };
  }
  wrapper.arity = 8;
  wrapper.func = fun;
  return wrapper;
}

function F9(fun)
{
  function wrapper(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) { return function(i) {
    return fun(a, b, c, d, e, f, g, h, i); }; }; }; }; }; }; }; };
  }
  wrapper.arity = 9;
  wrapper.func = fun;
  return wrapper;
}

function A2(fun, a, b)
{
  return fun.arity === 2
    ? fun.func(a, b)
    : fun(a)(b);
}
function A3(fun, a, b, c)
{
  return fun.arity === 3
    ? fun.func(a, b, c)
    : fun(a)(b)(c);
}
function A4(fun, a, b, c, d)
{
  return fun.arity === 4
    ? fun.func(a, b, c, d)
    : fun(a)(b)(c)(d);
}
function A5(fun, a, b, c, d, e)
{
  return fun.arity === 5
    ? fun.func(a, b, c, d, e)
    : fun(a)(b)(c)(d)(e);
}
function A6(fun, a, b, c, d, e, f)
{
  return fun.arity === 6
    ? fun.func(a, b, c, d, e, f)
    : fun(a)(b)(c)(d)(e)(f);
}
function A7(fun, a, b, c, d, e, f, g)
{
  return fun.arity === 7
    ? fun.func(a, b, c, d, e, f, g)
    : fun(a)(b)(c)(d)(e)(f)(g);
}
function A8(fun, a, b, c, d, e, f, g, h)
{
  return fun.arity === 8
    ? fun.func(a, b, c, d, e, f, g, h)
    : fun(a)(b)(c)(d)(e)(f)(g)(h);
}
function A9(fun, a, b, c, d, e, f, g, h, i)
{
  return fun.arity === 9
    ? fun.func(a, b, c, d, e, f, g, h, i)
    : fun(a)(b)(c)(d)(e)(f)(g)(h)(i);
}

//import Native.List //

var _elm_lang$core$Native_Array = function() {

// A RRB-Tree has two distinct data types.
// Leaf -> "height"  is always 0
//         "table"   is an array of elements
// Node -> "height"  is always greater than 0
//         "table"   is an array of child nodes
//         "lengths" is an array of accumulated lengths of the child nodes

// M is the maximal table size. 32 seems fast. E is the allowed increase
// of search steps when concatting to find an index. Lower values will
// decrease balancing, but will increase search steps.
var M = 32;
var E = 2;

// An empty array.
var empty = {
	ctor: '_Array',
	height: 0,
	table: []
};


function get(i, array)
{
	if (i < 0 || i >= length(array))
	{
		throw new Error(
			'Index ' + i + ' is out of range. Check the length of ' +
			'your array first or use getMaybe or getWithDefault.');
	}
	return unsafeGet(i, array);
}


function unsafeGet(i, array)
{
	for (var x = array.height; x > 0; x--)
	{
		var slot = i >> (x * 5);
		while (array.lengths[slot] <= i)
		{
			slot++;
		}
		if (slot > 0)
		{
			i -= array.lengths[slot - 1];
		}
		array = array.table[slot];
	}
	return array.table[i];
}


// Sets the value at the index i. Only the nodes leading to i will get
// copied and updated.
function set(i, item, array)
{
	if (i < 0 || length(array) <= i)
	{
		return array;
	}
	return unsafeSet(i, item, array);
}


function unsafeSet(i, item, array)
{
	array = nodeCopy(array);

	if (array.height === 0)
	{
		array.table[i] = item;
	}
	else
	{
		var slot = getSlot(i, array);
		if (slot > 0)
		{
			i -= array.lengths[slot - 1];
		}
		array.table[slot] = unsafeSet(i, item, array.table[slot]);
	}
	return array;
}


function initialize(len, f)
{
	if (len <= 0)
	{
		return empty;
	}
	var h = Math.floor( Math.log(len) / Math.log(M) );
	return initialize_(f, h, 0, len);
}

function initialize_(f, h, from, to)
{
	if (h === 0)
	{
		var table = new Array((to - from) % (M + 1));
		for (var i = 0; i < table.length; i++)
		{
		  table[i] = f(from + i);
		}
		return {
			ctor: '_Array',
			height: 0,
			table: table
		};
	}

	var step = Math.pow(M, h);
	var table = new Array(Math.ceil((to - from) / step));
	var lengths = new Array(table.length);
	for (var i = 0; i < table.length; i++)
	{
		table[i] = initialize_(f, h - 1, from + (i * step), Math.min(from + ((i + 1) * step), to));
		lengths[i] = length(table[i]) + (i > 0 ? lengths[i-1] : 0);
	}
	return {
		ctor: '_Array',
		height: h,
		table: table,
		lengths: lengths
	};
}

function fromList(list)
{
	if (list.ctor === '[]')
	{
		return empty;
	}

	// Allocate M sized blocks (table) and write list elements to it.
	var table = new Array(M);
	var nodes = [];
	var i = 0;

	while (list.ctor !== '[]')
	{
		table[i] = list._0;
		list = list._1;
		i++;

		// table is full, so we can push a leaf containing it into the
		// next node.
		if (i === M)
		{
			var leaf = {
				ctor: '_Array',
				height: 0,
				table: table
			};
			fromListPush(leaf, nodes);
			table = new Array(M);
			i = 0;
		}
	}

	// Maybe there is something left on the table.
	if (i > 0)
	{
		var leaf = {
			ctor: '_Array',
			height: 0,
			table: table.splice(0, i)
		};
		fromListPush(leaf, nodes);
	}

	// Go through all of the nodes and eventually push them into higher nodes.
	for (var h = 0; h < nodes.length - 1; h++)
	{
		if (nodes[h].table.length > 0)
		{
			fromListPush(nodes[h], nodes);
		}
	}

	var head = nodes[nodes.length - 1];
	if (head.height > 0 && head.table.length === 1)
	{
		return head.table[0];
	}
	else
	{
		return head;
	}
}

// Push a node into a higher node as a child.
function fromListPush(toPush, nodes)
{
	var h = toPush.height;

	// Maybe the node on this height does not exist.
	if (nodes.length === h)
	{
		var node = {
			ctor: '_Array',
			height: h + 1,
			table: [],
			lengths: []
		};
		nodes.push(node);
	}

	nodes[h].table.push(toPush);
	var len = length(toPush);
	if (nodes[h].lengths.length > 0)
	{
		len += nodes[h].lengths[nodes[h].lengths.length - 1];
	}
	nodes[h].lengths.push(len);

	if (nodes[h].table.length === M)
	{
		fromListPush(nodes[h], nodes);
		nodes[h] = {
			ctor: '_Array',
			height: h + 1,
			table: [],
			lengths: []
		};
	}
}

// Pushes an item via push_ to the bottom right of a tree.
function push(item, a)
{
	var pushed = push_(item, a);
	if (pushed !== null)
	{
		return pushed;
	}

	var newTree = create(item, a.height);
	return siblise(a, newTree);
}

// Recursively tries to push an item to the bottom-right most
// tree possible. If there is no space left for the item,
// null will be returned.
function push_(item, a)
{
	// Handle resursion stop at leaf level.
	if (a.height === 0)
	{
		if (a.table.length < M)
		{
			var newA = {
				ctor: '_Array',
				height: 0,
				table: a.table.slice()
			};
			newA.table.push(item);
			return newA;
		}
		else
		{
		  return null;
		}
	}

	// Recursively push
	var pushed = push_(item, botRight(a));

	// There was space in the bottom right tree, so the slot will
	// be updated.
	if (pushed !== null)
	{
		var newA = nodeCopy(a);
		newA.table[newA.table.length - 1] = pushed;
		newA.lengths[newA.lengths.length - 1]++;
		return newA;
	}

	// When there was no space left, check if there is space left
	// for a new slot with a tree which contains only the item
	// at the bottom.
	if (a.table.length < M)
	{
		var newSlot = create(item, a.height - 1);
		var newA = nodeCopy(a);
		newA.table.push(newSlot);
		newA.lengths.push(newA.lengths[newA.lengths.length - 1] + length(newSlot));
		return newA;
	}
	else
	{
		return null;
	}
}

// Converts an array into a list of elements.
function toList(a)
{
	return toList_(_elm_lang$core$Native_List.Nil, a);
}

function toList_(list, a)
{
	for (var i = a.table.length - 1; i >= 0; i--)
	{
		list =
			a.height === 0
				? _elm_lang$core$Native_List.Cons(a.table[i], list)
				: toList_(list, a.table[i]);
	}
	return list;
}

// Maps a function over the elements of an array.
function map(f, a)
{
	var newA = {
		ctor: '_Array',
		height: a.height,
		table: new Array(a.table.length)
	};
	if (a.height > 0)
	{
		newA.lengths = a.lengths;
	}
	for (var i = 0; i < a.table.length; i++)
	{
		newA.table[i] =
			a.height === 0
				? f(a.table[i])
				: map(f, a.table[i]);
	}
	return newA;
}

// Maps a function over the elements with their index as first argument.
function indexedMap(f, a)
{
	return indexedMap_(f, a, 0);
}

function indexedMap_(f, a, from)
{
	var newA = {
		ctor: '_Array',
		height: a.height,
		table: new Array(a.table.length)
	};
	if (a.height > 0)
	{
		newA.lengths = a.lengths;
	}
	for (var i = 0; i < a.table.length; i++)
	{
		newA.table[i] =
			a.height === 0
				? A2(f, from + i, a.table[i])
				: indexedMap_(f, a.table[i], i == 0 ? from : from + a.lengths[i - 1]);
	}
	return newA;
}

function foldl(f, b, a)
{
	if (a.height === 0)
	{
		for (var i = 0; i < a.table.length; i++)
		{
			b = A2(f, a.table[i], b);
		}
	}
	else
	{
		for (var i = 0; i < a.table.length; i++)
		{
			b = foldl(f, b, a.table[i]);
		}
	}
	return b;
}

function foldr(f, b, a)
{
	if (a.height === 0)
	{
		for (var i = a.table.length; i--; )
		{
			b = A2(f, a.table[i], b);
		}
	}
	else
	{
		for (var i = a.table.length; i--; )
		{
			b = foldr(f, b, a.table[i]);
		}
	}
	return b;
}

// TODO: currently, it slices the right, then the left. This can be
// optimized.
function slice(from, to, a)
{
	if (from < 0)
	{
		from += length(a);
	}
	if (to < 0)
	{
		to += length(a);
	}
	return sliceLeft(from, sliceRight(to, a));
}

function sliceRight(to, a)
{
	if (to === length(a))
	{
		return a;
	}

	// Handle leaf level.
	if (a.height === 0)
	{
		var newA = { ctor:'_Array', height:0 };
		newA.table = a.table.slice(0, to);
		return newA;
	}

	// Slice the right recursively.
	var right = getSlot(to, a);
	var sliced = sliceRight(to - (right > 0 ? a.lengths[right - 1] : 0), a.table[right]);

	// Maybe the a node is not even needed, as sliced contains the whole slice.
	if (right === 0)
	{
		return sliced;
	}

	// Create new node.
	var newA = {
		ctor: '_Array',
		height: a.height,
		table: a.table.slice(0, right),
		lengths: a.lengths.slice(0, right)
	};
	if (sliced.table.length > 0)
	{
		newA.table[right] = sliced;
		newA.lengths[right] = length(sliced) + (right > 0 ? newA.lengths[right - 1] : 0);
	}
	return newA;
}

function sliceLeft(from, a)
{
	if (from === 0)
	{
		return a;
	}

	// Handle leaf level.
	if (a.height === 0)
	{
		var newA = { ctor:'_Array', height:0 };
		newA.table = a.table.slice(from, a.table.length + 1);
		return newA;
	}

	// Slice the left recursively.
	var left = getSlot(from, a);
	var sliced = sliceLeft(from - (left > 0 ? a.lengths[left - 1] : 0), a.table[left]);

	// Maybe the a node is not even needed, as sliced contains the whole slice.
	if (left === a.table.length - 1)
	{
		return sliced;
	}

	// Create new node.
	var newA = {
		ctor: '_Array',
		height: a.height,
		table: a.table.slice(left, a.table.length + 1),
		lengths: new Array(a.table.length - left)
	};
	newA.table[0] = sliced;
	var len = 0;
	for (var i = 0; i < newA.table.length; i++)
	{
		len += length(newA.table[i]);
		newA.lengths[i] = len;
	}

	return newA;
}

// Appends two trees.
function append(a,b)
{
	if (a.table.length === 0)
	{
		return b;
	}
	if (b.table.length === 0)
	{
		return a;
	}

	var c = append_(a, b);

	// Check if both nodes can be crunshed together.
	if (c[0].table.length + c[1].table.length <= M)
	{
		if (c[0].table.length === 0)
		{
			return c[1];
		}
		if (c[1].table.length === 0)
		{
			return c[0];
		}

		// Adjust .table and .lengths
		c[0].table = c[0].table.concat(c[1].table);
		if (c[0].height > 0)
		{
			var len = length(c[0]);
			for (var i = 0; i < c[1].lengths.length; i++)
			{
				c[1].lengths[i] += len;
			}
			c[0].lengths = c[0].lengths.concat(c[1].lengths);
		}

		return c[0];
	}

	if (c[0].height > 0)
	{
		var toRemove = calcToRemove(a, b);
		if (toRemove > E)
		{
			c = shuffle(c[0], c[1], toRemove);
		}
	}

	return siblise(c[0], c[1]);
}

// Returns an array of two nodes; right and left. One node _may_ be empty.
function append_(a, b)
{
	if (a.height === 0 && b.height === 0)
	{
		return [a, b];
	}

	if (a.height !== 1 || b.height !== 1)
	{
		if (a.height === b.height)
		{
			a = nodeCopy(a);
			b = nodeCopy(b);
			var appended = append_(botRight(a), botLeft(b));

			insertRight(a, appended[1]);
			insertLeft(b, appended[0]);
		}
		else if (a.height > b.height)
		{
			a = nodeCopy(a);
			var appended = append_(botRight(a), b);

			insertRight(a, appended[0]);
			b = parentise(appended[1], appended[1].height + 1);
		}
		else
		{
			b = nodeCopy(b);
			var appended = append_(a, botLeft(b));

			var left = appended[0].table.length === 0 ? 0 : 1;
			var right = left === 0 ? 1 : 0;
			insertLeft(b, appended[left]);
			a = parentise(appended[right], appended[right].height + 1);
		}
	}

	// Check if balancing is needed and return based on that.
	if (a.table.length === 0 || b.table.length === 0)
	{
		return [a, b];
	}

	var toRemove = calcToRemove(a, b);
	if (toRemove <= E)
	{
		return [a, b];
	}
	return shuffle(a, b, toRemove);
}

// Helperfunctions for append_. Replaces a child node at the side of the parent.
function insertRight(parent, node)
{
	var index = parent.table.length - 1;
	parent.table[index] = node;
	parent.lengths[index] = length(node);
	parent.lengths[index] += index > 0 ? parent.lengths[index - 1] : 0;
}

function insertLeft(parent, node)
{
	if (node.table.length > 0)
	{
		parent.table[0] = node;
		parent.lengths[0] = length(node);

		var len = length(parent.table[0]);
		for (var i = 1; i < parent.lengths.length; i++)
		{
			len += length(parent.table[i]);
			parent.lengths[i] = len;
		}
	}
	else
	{
		parent.table.shift();
		for (var i = 1; i < parent.lengths.length; i++)
		{
			parent.lengths[i] = parent.lengths[i] - parent.lengths[0];
		}
		parent.lengths.shift();
	}
}

// Returns the extra search steps for E. Refer to the paper.
function calcToRemove(a, b)
{
	var subLengths = 0;
	for (var i = 0; i < a.table.length; i++)
	{
		subLengths += a.table[i].table.length;
	}
	for (var i = 0; i < b.table.length; i++)
	{
		subLengths += b.table[i].table.length;
	}

	var toRemove = a.table.length + b.table.length;
	return toRemove - (Math.floor((subLengths - 1) / M) + 1);
}

// get2, set2 and saveSlot are helpers for accessing elements over two arrays.
function get2(a, b, index)
{
	return index < a.length
		? a[index]
		: b[index - a.length];
}

function set2(a, b, index, value)
{
	if (index < a.length)
	{
		a[index] = value;
	}
	else
	{
		b[index - a.length] = value;
	}
}

function saveSlot(a, b, index, slot)
{
	set2(a.table, b.table, index, slot);

	var l = (index === 0 || index === a.lengths.length)
		? 0
		: get2(a.lengths, a.lengths, index - 1);

	set2(a.lengths, b.lengths, index, l + length(slot));
}

// Creates a node or leaf with a given length at their arrays for perfomance.
// Is only used by shuffle.
function createNode(h, length)
{
	if (length < 0)
	{
		length = 0;
	}
	var a = {
		ctor: '_Array',
		height: h,
		table: new Array(length)
	};
	if (h > 0)
	{
		a.lengths = new Array(length);
	}
	return a;
}

// Returns an array of two balanced nodes.
function shuffle(a, b, toRemove)
{
	var newA = createNode(a.height, Math.min(M, a.table.length + b.table.length - toRemove));
	var newB = createNode(a.height, newA.table.length - (a.table.length + b.table.length - toRemove));

	// Skip the slots with size M. More precise: copy the slot references
	// to the new node
	var read = 0;
	while (get2(a.table, b.table, read).table.length % M === 0)
	{
		set2(newA.table, newB.table, read, get2(a.table, b.table, read));
		set2(newA.lengths, newB.lengths, read, get2(a.lengths, b.lengths, read));
		read++;
	}

	// Pulling items from left to right, caching in a slot before writing
	// it into the new nodes.
	var write = read;
	var slot = new createNode(a.height - 1, 0);
	var from = 0;

	// If the current slot is still containing data, then there will be at
	// least one more write, so we do not break this loop yet.
	while (read - write - (slot.table.length > 0 ? 1 : 0) < toRemove)
	{
		// Find out the max possible items for copying.
		var source = get2(a.table, b.table, read);
		var to = Math.min(M - slot.table.length, source.table.length);

		// Copy and adjust size table.
		slot.table = slot.table.concat(source.table.slice(from, to));
		if (slot.height > 0)
		{
			var len = slot.lengths.length;
			for (var i = len; i < len + to - from; i++)
			{
				slot.lengths[i] = length(slot.table[i]);
				slot.lengths[i] += (i > 0 ? slot.lengths[i - 1] : 0);
			}
		}

		from += to;

		// Only proceed to next slots[i] if the current one was
		// fully copied.
		if (source.table.length <= to)
		{
			read++; from = 0;
		}

		// Only create a new slot if the current one is filled up.
		if (slot.table.length === M)
		{
			saveSlot(newA, newB, write, slot);
			slot = createNode(a.height - 1, 0);
			write++;
		}
	}

	// Cleanup after the loop. Copy the last slot into the new nodes.
	if (slot.table.length > 0)
	{
		saveSlot(newA, newB, write, slot);
		write++;
	}

	// Shift the untouched slots to the left
	while (read < a.table.length + b.table.length )
	{
		saveSlot(newA, newB, write, get2(a.table, b.table, read));
		read++;
		write++;
	}

	return [newA, newB];
}

// Navigation functions
function botRight(a)
{
	return a.table[a.table.length - 1];
}
function botLeft(a)
{
	return a.table[0];
}

// Copies a node for updating. Note that you should not use this if
// only updating only one of "table" or "lengths" for performance reasons.
function nodeCopy(a)
{
	var newA = {
		ctor: '_Array',
		height: a.height,
		table: a.table.slice()
	};
	if (a.height > 0)
	{
		newA.lengths = a.lengths.slice();
	}
	return newA;
}

// Returns how many items are in the tree.
function length(array)
{
	if (array.height === 0)
	{
		return array.table.length;
	}
	else
	{
		return array.lengths[array.lengths.length - 1];
	}
}

// Calculates in which slot of "table" the item probably is, then
// find the exact slot via forward searching in  "lengths". Returns the index.
function getSlot(i, a)
{
	var slot = i >> (5 * a.height);
	while (a.lengths[slot] <= i)
	{
		slot++;
	}
	return slot;
}

// Recursively creates a tree with a given height containing
// only the given item.
function create(item, h)
{
	if (h === 0)
	{
		return {
			ctor: '_Array',
			height: 0,
			table: [item]
		};
	}
	return {
		ctor: '_Array',
		height: h,
		table: [create(item, h - 1)],
		lengths: [1]
	};
}

// Recursively creates a tree that contains the given tree.
function parentise(tree, h)
{
	if (h === tree.height)
	{
		return tree;
	}

	return {
		ctor: '_Array',
		height: h,
		table: [parentise(tree, h - 1)],
		lengths: [length(tree)]
	};
}

// Emphasizes blood brotherhood beneath two trees.
function siblise(a, b)
{
	return {
		ctor: '_Array',
		height: a.height + 1,
		table: [a, b],
		lengths: [length(a), length(a) + length(b)]
	};
}

function toJSArray(a)
{
	var jsArray = new Array(length(a));
	toJSArray_(jsArray, 0, a);
	return jsArray;
}

function toJSArray_(jsArray, i, a)
{
	for (var t = 0; t < a.table.length; t++)
	{
		if (a.height === 0)
		{
			jsArray[i + t] = a.table[t];
		}
		else
		{
			var inc = t === 0 ? 0 : a.lengths[t - 1];
			toJSArray_(jsArray, i + inc, a.table[t]);
		}
	}
}

function fromJSArray(jsArray)
{
	if (jsArray.length === 0)
	{
		return empty;
	}
	var h = Math.floor(Math.log(jsArray.length) / Math.log(M));
	return fromJSArray_(jsArray, h, 0, jsArray.length);
}

function fromJSArray_(jsArray, h, from, to)
{
	if (h === 0)
	{
		return {
			ctor: '_Array',
			height: 0,
			table: jsArray.slice(from, to)
		};
	}

	var step = Math.pow(M, h);
	var table = new Array(Math.ceil((to - from) / step));
	var lengths = new Array(table.length);
	for (var i = 0; i < table.length; i++)
	{
		table[i] = fromJSArray_(jsArray, h - 1, from + (i * step), Math.min(from + ((i + 1) * step), to));
		lengths[i] = length(table[i]) + (i > 0 ? lengths[i - 1] : 0);
	}
	return {
		ctor: '_Array',
		height: h,
		table: table,
		lengths: lengths
	};
}

return {
	empty: empty,
	fromList: fromList,
	toList: toList,
	initialize: F2(initialize),
	append: F2(append),
	push: F2(push),
	slice: F3(slice),
	get: F2(get),
	set: F3(set),
	map: F2(map),
	indexedMap: F2(indexedMap),
	foldl: F3(foldl),
	foldr: F3(foldr),
	length: length,

	toJSArray: toJSArray,
	fromJSArray: fromJSArray
};

}();
//import Native.Utils //

var _elm_lang$core$Native_Basics = function() {

function div(a, b)
{
	return (a / b) | 0;
}
function rem(a, b)
{
	return a % b;
}
function mod(a, b)
{
	if (b === 0)
	{
		throw new Error('Cannot perform mod 0. Division by zero error.');
	}
	var r = a % b;
	var m = a === 0 ? 0 : (b > 0 ? (a >= 0 ? r : r + b) : -mod(-a, -b));

	return m === b ? 0 : m;
}
function logBase(base, n)
{
	return Math.log(n) / Math.log(base);
}
function negate(n)
{
	return -n;
}
function abs(n)
{
	return n < 0 ? -n : n;
}

function min(a, b)
{
	return _elm_lang$core$Native_Utils.cmp(a, b) < 0 ? a : b;
}
function max(a, b)
{
	return _elm_lang$core$Native_Utils.cmp(a, b) > 0 ? a : b;
}
function clamp(lo, hi, n)
{
	return _elm_lang$core$Native_Utils.cmp(n, lo) < 0
		? lo
		: _elm_lang$core$Native_Utils.cmp(n, hi) > 0
			? hi
			: n;
}

var ord = ['LT', 'EQ', 'GT'];

function compare(x, y)
{
	return { ctor: ord[_elm_lang$core$Native_Utils.cmp(x, y) + 1] };
}

function xor(a, b)
{
	return a !== b;
}
function not(b)
{
	return !b;
}
function isInfinite(n)
{
	return n === Infinity || n === -Infinity;
}

function truncate(n)
{
	return n | 0;
}

function degrees(d)
{
	return d * Math.PI / 180;
}
function turns(t)
{
	return 2 * Math.PI * t;
}
function fromPolar(point)
{
	var r = point._0;
	var t = point._1;
	return _elm_lang$core$Native_Utils.Tuple2(r * Math.cos(t), r * Math.sin(t));
}
function toPolar(point)
{
	var x = point._0;
	var y = point._1;
	return _elm_lang$core$Native_Utils.Tuple2(Math.sqrt(x * x + y * y), Math.atan2(y, x));
}

return {
	div: F2(div),
	rem: F2(rem),
	mod: F2(mod),

	pi: Math.PI,
	e: Math.E,
	cos: Math.cos,
	sin: Math.sin,
	tan: Math.tan,
	acos: Math.acos,
	asin: Math.asin,
	atan: Math.atan,
	atan2: F2(Math.atan2),

	degrees: degrees,
	turns: turns,
	fromPolar: fromPolar,
	toPolar: toPolar,

	sqrt: Math.sqrt,
	logBase: F2(logBase),
	negate: negate,
	abs: abs,
	min: F2(min),
	max: F2(max),
	clamp: F3(clamp),
	compare: F2(compare),

	xor: F2(xor),
	not: not,

	truncate: truncate,
	ceiling: Math.ceil,
	floor: Math.floor,
	round: Math.round,
	toFloat: function(x) { return x; },
	isNaN: isNaN,
	isInfinite: isInfinite
};

}();
//import //

var _elm_lang$core$Native_Utils = function() {

// COMPARISONS

function eq(x, y)
{
	var stack = [];
	var isEqual = eqHelp(x, y, 0, stack);
	var pair;
	while (isEqual && (pair = stack.pop()))
	{
		isEqual = eqHelp(pair.x, pair.y, 0, stack);
	}
	return isEqual;
}


function eqHelp(x, y, depth, stack)
{
	if (depth > 100)
	{
		stack.push({ x: x, y: y });
		return true;
	}

	if (x === y)
	{
		return true;
	}

	if (typeof x !== 'object')
	{
		if (typeof x === 'function')
		{
			throw new Error(
				'Trying to use `(==)` on functions. There is no way to know if functions are "the same" in the Elm sense.'
				+ ' Read more about this at http://package.elm-lang.org/packages/elm-lang/core/latest/Basics#=='
				+ ' which describes why it is this way and what the better version will look like.'
			);
		}
		return false;
	}

	if (x === null || y === null)
	{
		return false
	}

	if (x instanceof Date)
	{
		return x.getTime() === y.getTime();
	}

	if (!('ctor' in x))
	{
		for (var key in x)
		{
			if (!eqHelp(x[key], y[key], depth + 1, stack))
			{
				return false;
			}
		}
		return true;
	}

	// convert Dicts and Sets to lists
	if (x.ctor === 'RBNode_elm_builtin' || x.ctor === 'RBEmpty_elm_builtin')
	{
		x = _elm_lang$core$Dict$toList(x);
		y = _elm_lang$core$Dict$toList(y);
	}
	if (x.ctor === 'Set_elm_builtin')
	{
		x = _elm_lang$core$Set$toList(x);
		y = _elm_lang$core$Set$toList(y);
	}

	// check if lists are equal without recursion
	if (x.ctor === '::')
	{
		var a = x;
		var b = y;
		while (a.ctor === '::' && b.ctor === '::')
		{
			if (!eqHelp(a._0, b._0, depth + 1, stack))
			{
				return false;
			}
			a = a._1;
			b = b._1;
		}
		return a.ctor === b.ctor;
	}

	// check if Arrays are equal
	if (x.ctor === '_Array')
	{
		var xs = _elm_lang$core$Native_Array.toJSArray(x);
		var ys = _elm_lang$core$Native_Array.toJSArray(y);
		if (xs.length !== ys.length)
		{
			return false;
		}
		for (var i = 0; i < xs.length; i++)
		{
			if (!eqHelp(xs[i], ys[i], depth + 1, stack))
			{
				return false;
			}
		}
		return true;
	}

	if (!eqHelp(x.ctor, y.ctor, depth + 1, stack))
	{
		return false;
	}

	for (var key in x)
	{
		if (!eqHelp(x[key], y[key], depth + 1, stack))
		{
			return false;
		}
	}
	return true;
}

// Code in Generate/JavaScript.hs, Basics.js, and List.js depends on
// the particular integer values assigned to LT, EQ, and GT.

var LT = -1, EQ = 0, GT = 1;

function cmp(x, y)
{
	if (typeof x !== 'object')
	{
		return x === y ? EQ : x < y ? LT : GT;
	}

	if (x instanceof String)
	{
		var a = x.valueOf();
		var b = y.valueOf();
		return a === b ? EQ : a < b ? LT : GT;
	}

	if (x.ctor === '::' || x.ctor === '[]')
	{
		while (x.ctor === '::' && y.ctor === '::')
		{
			var ord = cmp(x._0, y._0);
			if (ord !== EQ)
			{
				return ord;
			}
			x = x._1;
			y = y._1;
		}
		return x.ctor === y.ctor ? EQ : x.ctor === '[]' ? LT : GT;
	}

	if (x.ctor.slice(0, 6) === '_Tuple')
	{
		var ord;
		var n = x.ctor.slice(6) - 0;
		var err = 'cannot compare tuples with more than 6 elements.';
		if (n === 0) return EQ;
		if (n >= 1) { ord = cmp(x._0, y._0); if (ord !== EQ) return ord;
		if (n >= 2) { ord = cmp(x._1, y._1); if (ord !== EQ) return ord;
		if (n >= 3) { ord = cmp(x._2, y._2); if (ord !== EQ) return ord;
		if (n >= 4) { ord = cmp(x._3, y._3); if (ord !== EQ) return ord;
		if (n >= 5) { ord = cmp(x._4, y._4); if (ord !== EQ) return ord;
		if (n >= 6) { ord = cmp(x._5, y._5); if (ord !== EQ) return ord;
		if (n >= 7) throw new Error('Comparison error: ' + err); } } } } } }
		return EQ;
	}

	throw new Error(
		'Comparison error: comparison is only defined on ints, '
		+ 'floats, times, chars, strings, lists of comparable values, '
		+ 'and tuples of comparable values.'
	);
}


// COMMON VALUES

var Tuple0 = {
	ctor: '_Tuple0'
};

function Tuple2(x, y)
{
	return {
		ctor: '_Tuple2',
		_0: x,
		_1: y
	};
}

function chr(c)
{
	return new String(c);
}


// GUID

var count = 0;
function guid(_)
{
	return count++;
}


// RECORDS

function update(oldRecord, updatedFields)
{
	var newRecord = {};

	for (var key in oldRecord)
	{
		newRecord[key] = oldRecord[key];
	}

	for (var key in updatedFields)
	{
		newRecord[key] = updatedFields[key];
	}

	return newRecord;
}


//// LIST STUFF ////

var Nil = { ctor: '[]' };

function Cons(hd, tl)
{
	return {
		ctor: '::',
		_0: hd,
		_1: tl
	};
}

function append(xs, ys)
{
	// append Strings
	if (typeof xs === 'string')
	{
		return xs + ys;
	}

	// append Lists
	if (xs.ctor === '[]')
	{
		return ys;
	}
	var root = Cons(xs._0, Nil);
	var curr = root;
	xs = xs._1;
	while (xs.ctor !== '[]')
	{
		curr._1 = Cons(xs._0, Nil);
		xs = xs._1;
		curr = curr._1;
	}
	curr._1 = ys;
	return root;
}


// CRASHES

function crash(moduleName, region)
{
	return function(message) {
		throw new Error(
			'Ran into a `Debug.crash` in module `' + moduleName + '` ' + regionToString(region) + '\n'
			+ 'The message provided by the code author is:\n\n    '
			+ message
		);
	};
}

function crashCase(moduleName, region, value)
{
	return function(message) {
		throw new Error(
			'Ran into a `Debug.crash` in module `' + moduleName + '`\n\n'
			+ 'This was caused by the `case` expression ' + regionToString(region) + '.\n'
			+ 'One of the branches ended with a crash and the following value got through:\n\n    ' + toString(value) + '\n\n'
			+ 'The message provided by the code author is:\n\n    '
			+ message
		);
	};
}

function regionToString(region)
{
	if (region.start.line == region.end.line)
	{
		return 'on line ' + region.start.line;
	}
	return 'between lines ' + region.start.line + ' and ' + region.end.line;
}


// TO STRING

function toString(v)
{
	var type = typeof v;
	if (type === 'function')
	{
		var name = v.func ? v.func.name : v.name;
		return '<function' + (name === '' ? '' : ':') + name + '>';
	}

	if (type === 'boolean')
	{
		return v ? 'True' : 'False';
	}

	if (type === 'number')
	{
		return v + '';
	}

	if (v instanceof String)
	{
		return '\'' + addSlashes(v, true) + '\'';
	}

	if (type === 'string')
	{
		return '"' + addSlashes(v, false) + '"';
	}

	if (v === null)
	{
		return 'null';
	}

	if (type === 'object' && 'ctor' in v)
	{
		var ctorStarter = v.ctor.substring(0, 5);

		if (ctorStarter === '_Tupl')
		{
			var output = [];
			for (var k in v)
			{
				if (k === 'ctor') continue;
				output.push(toString(v[k]));
			}
			return '(' + output.join(',') + ')';
		}

		if (ctorStarter === '_Task')
		{
			return '<task>'
		}

		if (v.ctor === '_Array')
		{
			var list = _elm_lang$core$Array$toList(v);
			return 'Array.fromList ' + toString(list);
		}

		if (v.ctor === '<decoder>')
		{
			return '<decoder>';
		}

		if (v.ctor === '_Process')
		{
			return '<process:' + v.id + '>';
		}

		if (v.ctor === '::')
		{
			var output = '[' + toString(v._0);
			v = v._1;
			while (v.ctor === '::')
			{
				output += ',' + toString(v._0);
				v = v._1;
			}
			return output + ']';
		}

		if (v.ctor === '[]')
		{
			return '[]';
		}

		if (v.ctor === 'Set_elm_builtin')
		{
			return 'Set.fromList ' + toString(_elm_lang$core$Set$toList(v));
		}

		if (v.ctor === 'RBNode_elm_builtin' || v.ctor === 'RBEmpty_elm_builtin')
		{
			return 'Dict.fromList ' + toString(_elm_lang$core$Dict$toList(v));
		}

		var output = '';
		for (var i in v)
		{
			if (i === 'ctor') continue;
			var str = toString(v[i]);
			var c0 = str[0];
			var parenless = c0 === '{' || c0 === '(' || c0 === '<' || c0 === '"' || str.indexOf(' ') < 0;
			output += ' ' + (parenless ? str : '(' + str + ')');
		}
		return v.ctor + output;
	}

	if (type === 'object')
	{
		if (v instanceof Date)
		{
			return '<' + v.toString() + '>';
		}

		if (v.elm_web_socket)
		{
			return '<websocket>';
		}

		var output = [];
		for (var k in v)
		{
			output.push(k + ' = ' + toString(v[k]));
		}
		if (output.length === 0)
		{
			return '{}';
		}
		return '{ ' + output.join(', ') + ' }';
	}

	return '<internal structure>';
}

function addSlashes(str, isChar)
{
	var s = str.replace(/\\/g, '\\\\')
			  .replace(/\n/g, '\\n')
			  .replace(/\t/g, '\\t')
			  .replace(/\r/g, '\\r')
			  .replace(/\v/g, '\\v')
			  .replace(/\0/g, '\\0');
	if (isChar)
	{
		return s.replace(/\'/g, '\\\'');
	}
	else
	{
		return s.replace(/\"/g, '\\"');
	}
}


return {
	eq: eq,
	cmp: cmp,
	Tuple0: Tuple0,
	Tuple2: Tuple2,
	chr: chr,
	update: update,
	guid: guid,

	append: F2(append),

	crash: crash,
	crashCase: crashCase,

	toString: toString
};

}();
var _elm_lang$core$Basics$never = function (_p0) {
	never:
	while (true) {
		var _p1 = _p0;
		var _v1 = _p1._0;
		_p0 = _v1;
		continue never;
	}
};
var _elm_lang$core$Basics$uncurry = F2(
	function (f, _p2) {
		var _p3 = _p2;
		return A2(f, _p3._0, _p3._1);
	});
var _elm_lang$core$Basics$curry = F3(
	function (f, a, b) {
		return f(
			{ctor: '_Tuple2', _0: a, _1: b});
	});
var _elm_lang$core$Basics$flip = F3(
	function (f, b, a) {
		return A2(f, a, b);
	});
var _elm_lang$core$Basics$always = F2(
	function (a, _p4) {
		return a;
	});
var _elm_lang$core$Basics$identity = function (x) {
	return x;
};
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['<|'] = F2(
	function (f, x) {
		return f(x);
	});
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['|>'] = F2(
	function (x, f) {
		return f(x);
	});
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['>>'] = F3(
	function (f, g, x) {
		return g(
			f(x));
	});
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['<<'] = F3(
	function (g, f, x) {
		return g(
			f(x));
	});
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['++'] = _elm_lang$core$Native_Utils.append;
var _elm_lang$core$Basics$toString = _elm_lang$core$Native_Utils.toString;
var _elm_lang$core$Basics$isInfinite = _elm_lang$core$Native_Basics.isInfinite;
var _elm_lang$core$Basics$isNaN = _elm_lang$core$Native_Basics.isNaN;
var _elm_lang$core$Basics$toFloat = _elm_lang$core$Native_Basics.toFloat;
var _elm_lang$core$Basics$ceiling = _elm_lang$core$Native_Basics.ceiling;
var _elm_lang$core$Basics$floor = _elm_lang$core$Native_Basics.floor;
var _elm_lang$core$Basics$truncate = _elm_lang$core$Native_Basics.truncate;
var _elm_lang$core$Basics$round = _elm_lang$core$Native_Basics.round;
var _elm_lang$core$Basics$not = _elm_lang$core$Native_Basics.not;
var _elm_lang$core$Basics$xor = _elm_lang$core$Native_Basics.xor;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['||'] = _elm_lang$core$Native_Basics.or;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['&&'] = _elm_lang$core$Native_Basics.and;
var _elm_lang$core$Basics$max = _elm_lang$core$Native_Basics.max;
var _elm_lang$core$Basics$min = _elm_lang$core$Native_Basics.min;
var _elm_lang$core$Basics$compare = _elm_lang$core$Native_Basics.compare;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['>='] = _elm_lang$core$Native_Basics.ge;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['<='] = _elm_lang$core$Native_Basics.le;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['>'] = _elm_lang$core$Native_Basics.gt;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['<'] = _elm_lang$core$Native_Basics.lt;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['/='] = _elm_lang$core$Native_Basics.neq;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['=='] = _elm_lang$core$Native_Basics.eq;
var _elm_lang$core$Basics$e = _elm_lang$core$Native_Basics.e;
var _elm_lang$core$Basics$pi = _elm_lang$core$Native_Basics.pi;
var _elm_lang$core$Basics$clamp = _elm_lang$core$Native_Basics.clamp;
var _elm_lang$core$Basics$logBase = _elm_lang$core$Native_Basics.logBase;
var _elm_lang$core$Basics$abs = _elm_lang$core$Native_Basics.abs;
var _elm_lang$core$Basics$negate = _elm_lang$core$Native_Basics.negate;
var _elm_lang$core$Basics$sqrt = _elm_lang$core$Native_Basics.sqrt;
var _elm_lang$core$Basics$atan2 = _elm_lang$core$Native_Basics.atan2;
var _elm_lang$core$Basics$atan = _elm_lang$core$Native_Basics.atan;
var _elm_lang$core$Basics$asin = _elm_lang$core$Native_Basics.asin;
var _elm_lang$core$Basics$acos = _elm_lang$core$Native_Basics.acos;
var _elm_lang$core$Basics$tan = _elm_lang$core$Native_Basics.tan;
var _elm_lang$core$Basics$sin = _elm_lang$core$Native_Basics.sin;
var _elm_lang$core$Basics$cos = _elm_lang$core$Native_Basics.cos;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['^'] = _elm_lang$core$Native_Basics.exp;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['%'] = _elm_lang$core$Native_Basics.mod;
var _elm_lang$core$Basics$rem = _elm_lang$core$Native_Basics.rem;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['//'] = _elm_lang$core$Native_Basics.div;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['/'] = _elm_lang$core$Native_Basics.floatDiv;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['*'] = _elm_lang$core$Native_Basics.mul;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['-'] = _elm_lang$core$Native_Basics.sub;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['+'] = _elm_lang$core$Native_Basics.add;
var _elm_lang$core$Basics$toPolar = _elm_lang$core$Native_Basics.toPolar;
var _elm_lang$core$Basics$fromPolar = _elm_lang$core$Native_Basics.fromPolar;
var _elm_lang$core$Basics$turns = _elm_lang$core$Native_Basics.turns;
var _elm_lang$core$Basics$degrees = _elm_lang$core$Native_Basics.degrees;
var _elm_lang$core$Basics$radians = function (t) {
	return t;
};
var _elm_lang$core$Basics$GT = {ctor: 'GT'};
var _elm_lang$core$Basics$EQ = {ctor: 'EQ'};
var _elm_lang$core$Basics$LT = {ctor: 'LT'};
var _elm_lang$core$Basics$JustOneMore = function (a) {
	return {ctor: 'JustOneMore', _0: a};
};

var _elm_lang$core$Maybe$withDefault = F2(
	function ($default, maybe) {
		var _p0 = maybe;
		if (_p0.ctor === 'Just') {
			return _p0._0;
		} else {
			return $default;
		}
	});
var _elm_lang$core$Maybe$Nothing = {ctor: 'Nothing'};
var _elm_lang$core$Maybe$andThen = F2(
	function (callback, maybeValue) {
		var _p1 = maybeValue;
		if (_p1.ctor === 'Just') {
			return callback(_p1._0);
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_lang$core$Maybe$Just = function (a) {
	return {ctor: 'Just', _0: a};
};
var _elm_lang$core$Maybe$map = F2(
	function (f, maybe) {
		var _p2 = maybe;
		if (_p2.ctor === 'Just') {
			return _elm_lang$core$Maybe$Just(
				f(_p2._0));
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_lang$core$Maybe$map2 = F3(
	function (func, ma, mb) {
		var _p3 = {ctor: '_Tuple2', _0: ma, _1: mb};
		if (((_p3.ctor === '_Tuple2') && (_p3._0.ctor === 'Just')) && (_p3._1.ctor === 'Just')) {
			return _elm_lang$core$Maybe$Just(
				A2(func, _p3._0._0, _p3._1._0));
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_lang$core$Maybe$map3 = F4(
	function (func, ma, mb, mc) {
		var _p4 = {ctor: '_Tuple3', _0: ma, _1: mb, _2: mc};
		if ((((_p4.ctor === '_Tuple3') && (_p4._0.ctor === 'Just')) && (_p4._1.ctor === 'Just')) && (_p4._2.ctor === 'Just')) {
			return _elm_lang$core$Maybe$Just(
				A3(func, _p4._0._0, _p4._1._0, _p4._2._0));
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_lang$core$Maybe$map4 = F5(
	function (func, ma, mb, mc, md) {
		var _p5 = {ctor: '_Tuple4', _0: ma, _1: mb, _2: mc, _3: md};
		if (((((_p5.ctor === '_Tuple4') && (_p5._0.ctor === 'Just')) && (_p5._1.ctor === 'Just')) && (_p5._2.ctor === 'Just')) && (_p5._3.ctor === 'Just')) {
			return _elm_lang$core$Maybe$Just(
				A4(func, _p5._0._0, _p5._1._0, _p5._2._0, _p5._3._0));
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_lang$core$Maybe$map5 = F6(
	function (func, ma, mb, mc, md, me) {
		var _p6 = {ctor: '_Tuple5', _0: ma, _1: mb, _2: mc, _3: md, _4: me};
		if ((((((_p6.ctor === '_Tuple5') && (_p6._0.ctor === 'Just')) && (_p6._1.ctor === 'Just')) && (_p6._2.ctor === 'Just')) && (_p6._3.ctor === 'Just')) && (_p6._4.ctor === 'Just')) {
			return _elm_lang$core$Maybe$Just(
				A5(func, _p6._0._0, _p6._1._0, _p6._2._0, _p6._3._0, _p6._4._0));
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});

//import Native.Utils //

var _elm_lang$core$Native_List = function() {

var Nil = { ctor: '[]' };

function Cons(hd, tl)
{
	return { ctor: '::', _0: hd, _1: tl };
}

function fromArray(arr)
{
	var out = Nil;
	for (var i = arr.length; i--; )
	{
		out = Cons(arr[i], out);
	}
	return out;
}

function toArray(xs)
{
	var out = [];
	while (xs.ctor !== '[]')
	{
		out.push(xs._0);
		xs = xs._1;
	}
	return out;
}

function foldr(f, b, xs)
{
	var arr = toArray(xs);
	var acc = b;
	for (var i = arr.length; i--; )
	{
		acc = A2(f, arr[i], acc);
	}
	return acc;
}

function map2(f, xs, ys)
{
	var arr = [];
	while (xs.ctor !== '[]' && ys.ctor !== '[]')
	{
		arr.push(A2(f, xs._0, ys._0));
		xs = xs._1;
		ys = ys._1;
	}
	return fromArray(arr);
}

function map3(f, xs, ys, zs)
{
	var arr = [];
	while (xs.ctor !== '[]' && ys.ctor !== '[]' && zs.ctor !== '[]')
	{
		arr.push(A3(f, xs._0, ys._0, zs._0));
		xs = xs._1;
		ys = ys._1;
		zs = zs._1;
	}
	return fromArray(arr);
}

function map4(f, ws, xs, ys, zs)
{
	var arr = [];
	while (   ws.ctor !== '[]'
		   && xs.ctor !== '[]'
		   && ys.ctor !== '[]'
		   && zs.ctor !== '[]')
	{
		arr.push(A4(f, ws._0, xs._0, ys._0, zs._0));
		ws = ws._1;
		xs = xs._1;
		ys = ys._1;
		zs = zs._1;
	}
	return fromArray(arr);
}

function map5(f, vs, ws, xs, ys, zs)
{
	var arr = [];
	while (   vs.ctor !== '[]'
		   && ws.ctor !== '[]'
		   && xs.ctor !== '[]'
		   && ys.ctor !== '[]'
		   && zs.ctor !== '[]')
	{
		arr.push(A5(f, vs._0, ws._0, xs._0, ys._0, zs._0));
		vs = vs._1;
		ws = ws._1;
		xs = xs._1;
		ys = ys._1;
		zs = zs._1;
	}
	return fromArray(arr);
}

function sortBy(f, xs)
{
	return fromArray(toArray(xs).sort(function(a, b) {
		return _elm_lang$core$Native_Utils.cmp(f(a), f(b));
	}));
}

function sortWith(f, xs)
{
	return fromArray(toArray(xs).sort(function(a, b) {
		var ord = f(a)(b).ctor;
		return ord === 'EQ' ? 0 : ord === 'LT' ? -1 : 1;
	}));
}

return {
	Nil: Nil,
	Cons: Cons,
	cons: F2(Cons),
	toArray: toArray,
	fromArray: fromArray,

	foldr: F3(foldr),

	map2: F3(map2),
	map3: F4(map3),
	map4: F5(map4),
	map5: F6(map5),
	sortBy: F2(sortBy),
	sortWith: F2(sortWith)
};

}();
var _elm_lang$core$List$sortWith = _elm_lang$core$Native_List.sortWith;
var _elm_lang$core$List$sortBy = _elm_lang$core$Native_List.sortBy;
var _elm_lang$core$List$sort = function (xs) {
	return A2(_elm_lang$core$List$sortBy, _elm_lang$core$Basics$identity, xs);
};
var _elm_lang$core$List$drop = F2(
	function (n, list) {
		drop:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(n, 0) < 1) {
				return list;
			} else {
				var _p0 = list;
				if (_p0.ctor === '[]') {
					return list;
				} else {
					var _v1 = n - 1,
						_v2 = _p0._1;
					n = _v1;
					list = _v2;
					continue drop;
				}
			}
		}
	});
var _elm_lang$core$List$map5 = _elm_lang$core$Native_List.map5;
var _elm_lang$core$List$map4 = _elm_lang$core$Native_List.map4;
var _elm_lang$core$List$map3 = _elm_lang$core$Native_List.map3;
var _elm_lang$core$List$map2 = _elm_lang$core$Native_List.map2;
var _elm_lang$core$List$any = F2(
	function (isOkay, list) {
		any:
		while (true) {
			var _p1 = list;
			if (_p1.ctor === '[]') {
				return false;
			} else {
				if (isOkay(_p1._0)) {
					return true;
				} else {
					var _v4 = isOkay,
						_v5 = _p1._1;
					isOkay = _v4;
					list = _v5;
					continue any;
				}
			}
		}
	});
var _elm_lang$core$List$all = F2(
	function (isOkay, list) {
		return !A2(
			_elm_lang$core$List$any,
			function (_p2) {
				return !isOkay(_p2);
			},
			list);
	});
var _elm_lang$core$List$foldr = _elm_lang$core$Native_List.foldr;
var _elm_lang$core$List$foldl = F3(
	function (func, acc, list) {
		foldl:
		while (true) {
			var _p3 = list;
			if (_p3.ctor === '[]') {
				return acc;
			} else {
				var _v7 = func,
					_v8 = A2(func, _p3._0, acc),
					_v9 = _p3._1;
				func = _v7;
				acc = _v8;
				list = _v9;
				continue foldl;
			}
		}
	});
var _elm_lang$core$List$length = function (xs) {
	return A3(
		_elm_lang$core$List$foldl,
		F2(
			function (_p4, i) {
				return i + 1;
			}),
		0,
		xs);
};
var _elm_lang$core$List$sum = function (numbers) {
	return A3(
		_elm_lang$core$List$foldl,
		F2(
			function (x, y) {
				return x + y;
			}),
		0,
		numbers);
};
var _elm_lang$core$List$product = function (numbers) {
	return A3(
		_elm_lang$core$List$foldl,
		F2(
			function (x, y) {
				return x * y;
			}),
		1,
		numbers);
};
var _elm_lang$core$List$maximum = function (list) {
	var _p5 = list;
	if (_p5.ctor === '::') {
		return _elm_lang$core$Maybe$Just(
			A3(_elm_lang$core$List$foldl, _elm_lang$core$Basics$max, _p5._0, _p5._1));
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _elm_lang$core$List$minimum = function (list) {
	var _p6 = list;
	if (_p6.ctor === '::') {
		return _elm_lang$core$Maybe$Just(
			A3(_elm_lang$core$List$foldl, _elm_lang$core$Basics$min, _p6._0, _p6._1));
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _elm_lang$core$List$member = F2(
	function (x, xs) {
		return A2(
			_elm_lang$core$List$any,
			function (a) {
				return _elm_lang$core$Native_Utils.eq(a, x);
			},
			xs);
	});
var _elm_lang$core$List$isEmpty = function (xs) {
	var _p7 = xs;
	if (_p7.ctor === '[]') {
		return true;
	} else {
		return false;
	}
};
var _elm_lang$core$List$tail = function (list) {
	var _p8 = list;
	if (_p8.ctor === '::') {
		return _elm_lang$core$Maybe$Just(_p8._1);
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _elm_lang$core$List$head = function (list) {
	var _p9 = list;
	if (_p9.ctor === '::') {
		return _elm_lang$core$Maybe$Just(_p9._0);
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _elm_lang$core$List_ops = _elm_lang$core$List_ops || {};
_elm_lang$core$List_ops['::'] = _elm_lang$core$Native_List.cons;
var _elm_lang$core$List$map = F2(
	function (f, xs) {
		return A3(
			_elm_lang$core$List$foldr,
			F2(
				function (x, acc) {
					return {
						ctor: '::',
						_0: f(x),
						_1: acc
					};
				}),
			{ctor: '[]'},
			xs);
	});
var _elm_lang$core$List$filter = F2(
	function (pred, xs) {
		var conditionalCons = F2(
			function (front, back) {
				return pred(front) ? {ctor: '::', _0: front, _1: back} : back;
			});
		return A3(
			_elm_lang$core$List$foldr,
			conditionalCons,
			{ctor: '[]'},
			xs);
	});
var _elm_lang$core$List$maybeCons = F3(
	function (f, mx, xs) {
		var _p10 = f(mx);
		if (_p10.ctor === 'Just') {
			return {ctor: '::', _0: _p10._0, _1: xs};
		} else {
			return xs;
		}
	});
var _elm_lang$core$List$filterMap = F2(
	function (f, xs) {
		return A3(
			_elm_lang$core$List$foldr,
			_elm_lang$core$List$maybeCons(f),
			{ctor: '[]'},
			xs);
	});
var _elm_lang$core$List$reverse = function (list) {
	return A3(
		_elm_lang$core$List$foldl,
		F2(
			function (x, y) {
				return {ctor: '::', _0: x, _1: y};
			}),
		{ctor: '[]'},
		list);
};
var _elm_lang$core$List$scanl = F3(
	function (f, b, xs) {
		var scan1 = F2(
			function (x, accAcc) {
				var _p11 = accAcc;
				if (_p11.ctor === '::') {
					return {
						ctor: '::',
						_0: A2(f, x, _p11._0),
						_1: accAcc
					};
				} else {
					return {ctor: '[]'};
				}
			});
		return _elm_lang$core$List$reverse(
			A3(
				_elm_lang$core$List$foldl,
				scan1,
				{
					ctor: '::',
					_0: b,
					_1: {ctor: '[]'}
				},
				xs));
	});
var _elm_lang$core$List$append = F2(
	function (xs, ys) {
		var _p12 = ys;
		if (_p12.ctor === '[]') {
			return xs;
		} else {
			return A3(
				_elm_lang$core$List$foldr,
				F2(
					function (x, y) {
						return {ctor: '::', _0: x, _1: y};
					}),
				ys,
				xs);
		}
	});
var _elm_lang$core$List$concat = function (lists) {
	return A3(
		_elm_lang$core$List$foldr,
		_elm_lang$core$List$append,
		{ctor: '[]'},
		lists);
};
var _elm_lang$core$List$concatMap = F2(
	function (f, list) {
		return _elm_lang$core$List$concat(
			A2(_elm_lang$core$List$map, f, list));
	});
var _elm_lang$core$List$partition = F2(
	function (pred, list) {
		var step = F2(
			function (x, _p13) {
				var _p14 = _p13;
				var _p16 = _p14._0;
				var _p15 = _p14._1;
				return pred(x) ? {
					ctor: '_Tuple2',
					_0: {ctor: '::', _0: x, _1: _p16},
					_1: _p15
				} : {
					ctor: '_Tuple2',
					_0: _p16,
					_1: {ctor: '::', _0: x, _1: _p15}
				};
			});
		return A3(
			_elm_lang$core$List$foldr,
			step,
			{
				ctor: '_Tuple2',
				_0: {ctor: '[]'},
				_1: {ctor: '[]'}
			},
			list);
	});
var _elm_lang$core$List$unzip = function (pairs) {
	var step = F2(
		function (_p18, _p17) {
			var _p19 = _p18;
			var _p20 = _p17;
			return {
				ctor: '_Tuple2',
				_0: {ctor: '::', _0: _p19._0, _1: _p20._0},
				_1: {ctor: '::', _0: _p19._1, _1: _p20._1}
			};
		});
	return A3(
		_elm_lang$core$List$foldr,
		step,
		{
			ctor: '_Tuple2',
			_0: {ctor: '[]'},
			_1: {ctor: '[]'}
		},
		pairs);
};
var _elm_lang$core$List$intersperse = F2(
	function (sep, xs) {
		var _p21 = xs;
		if (_p21.ctor === '[]') {
			return {ctor: '[]'};
		} else {
			var step = F2(
				function (x, rest) {
					return {
						ctor: '::',
						_0: sep,
						_1: {ctor: '::', _0: x, _1: rest}
					};
				});
			var spersed = A3(
				_elm_lang$core$List$foldr,
				step,
				{ctor: '[]'},
				_p21._1);
			return {ctor: '::', _0: _p21._0, _1: spersed};
		}
	});
var _elm_lang$core$List$takeReverse = F3(
	function (n, list, taken) {
		takeReverse:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(n, 0) < 1) {
				return taken;
			} else {
				var _p22 = list;
				if (_p22.ctor === '[]') {
					return taken;
				} else {
					var _v23 = n - 1,
						_v24 = _p22._1,
						_v25 = {ctor: '::', _0: _p22._0, _1: taken};
					n = _v23;
					list = _v24;
					taken = _v25;
					continue takeReverse;
				}
			}
		}
	});
var _elm_lang$core$List$takeTailRec = F2(
	function (n, list) {
		return _elm_lang$core$List$reverse(
			A3(
				_elm_lang$core$List$takeReverse,
				n,
				list,
				{ctor: '[]'}));
	});
var _elm_lang$core$List$takeFast = F3(
	function (ctr, n, list) {
		if (_elm_lang$core$Native_Utils.cmp(n, 0) < 1) {
			return {ctor: '[]'};
		} else {
			var _p23 = {ctor: '_Tuple2', _0: n, _1: list};
			_v26_5:
			do {
				_v26_1:
				do {
					if (_p23.ctor === '_Tuple2') {
						if (_p23._1.ctor === '[]') {
							return list;
						} else {
							if (_p23._1._1.ctor === '::') {
								switch (_p23._0) {
									case 1:
										break _v26_1;
									case 2:
										return {
											ctor: '::',
											_0: _p23._1._0,
											_1: {
												ctor: '::',
												_0: _p23._1._1._0,
												_1: {ctor: '[]'}
											}
										};
									case 3:
										if (_p23._1._1._1.ctor === '::') {
											return {
												ctor: '::',
												_0: _p23._1._0,
												_1: {
													ctor: '::',
													_0: _p23._1._1._0,
													_1: {
														ctor: '::',
														_0: _p23._1._1._1._0,
														_1: {ctor: '[]'}
													}
												}
											};
										} else {
											break _v26_5;
										}
									default:
										if ((_p23._1._1._1.ctor === '::') && (_p23._1._1._1._1.ctor === '::')) {
											var _p28 = _p23._1._1._1._0;
											var _p27 = _p23._1._1._0;
											var _p26 = _p23._1._0;
											var _p25 = _p23._1._1._1._1._0;
											var _p24 = _p23._1._1._1._1._1;
											return (_elm_lang$core$Native_Utils.cmp(ctr, 1000) > 0) ? {
												ctor: '::',
												_0: _p26,
												_1: {
													ctor: '::',
													_0: _p27,
													_1: {
														ctor: '::',
														_0: _p28,
														_1: {
															ctor: '::',
															_0: _p25,
															_1: A2(_elm_lang$core$List$takeTailRec, n - 4, _p24)
														}
													}
												}
											} : {
												ctor: '::',
												_0: _p26,
												_1: {
													ctor: '::',
													_0: _p27,
													_1: {
														ctor: '::',
														_0: _p28,
														_1: {
															ctor: '::',
															_0: _p25,
															_1: A3(_elm_lang$core$List$takeFast, ctr + 1, n - 4, _p24)
														}
													}
												}
											};
										} else {
											break _v26_5;
										}
								}
							} else {
								if (_p23._0 === 1) {
									break _v26_1;
								} else {
									break _v26_5;
								}
							}
						}
					} else {
						break _v26_5;
					}
				} while(false);
				return {
					ctor: '::',
					_0: _p23._1._0,
					_1: {ctor: '[]'}
				};
			} while(false);
			return list;
		}
	});
var _elm_lang$core$List$take = F2(
	function (n, list) {
		return A3(_elm_lang$core$List$takeFast, 0, n, list);
	});
var _elm_lang$core$List$repeatHelp = F3(
	function (result, n, value) {
		repeatHelp:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(n, 0) < 1) {
				return result;
			} else {
				var _v27 = {ctor: '::', _0: value, _1: result},
					_v28 = n - 1,
					_v29 = value;
				result = _v27;
				n = _v28;
				value = _v29;
				continue repeatHelp;
			}
		}
	});
var _elm_lang$core$List$repeat = F2(
	function (n, value) {
		return A3(
			_elm_lang$core$List$repeatHelp,
			{ctor: '[]'},
			n,
			value);
	});
var _elm_lang$core$List$rangeHelp = F3(
	function (lo, hi, list) {
		rangeHelp:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(lo, hi) < 1) {
				var _v30 = lo,
					_v31 = hi - 1,
					_v32 = {ctor: '::', _0: hi, _1: list};
				lo = _v30;
				hi = _v31;
				list = _v32;
				continue rangeHelp;
			} else {
				return list;
			}
		}
	});
var _elm_lang$core$List$range = F2(
	function (lo, hi) {
		return A3(
			_elm_lang$core$List$rangeHelp,
			lo,
			hi,
			{ctor: '[]'});
	});
var _elm_lang$core$List$indexedMap = F2(
	function (f, xs) {
		return A3(
			_elm_lang$core$List$map2,
			f,
			A2(
				_elm_lang$core$List$range,
				0,
				_elm_lang$core$List$length(xs) - 1),
			xs);
	});

var _elm_lang$core$Array$append = _elm_lang$core$Native_Array.append;
var _elm_lang$core$Array$length = _elm_lang$core$Native_Array.length;
var _elm_lang$core$Array$isEmpty = function (array) {
	return _elm_lang$core$Native_Utils.eq(
		_elm_lang$core$Array$length(array),
		0);
};
var _elm_lang$core$Array$slice = _elm_lang$core$Native_Array.slice;
var _elm_lang$core$Array$set = _elm_lang$core$Native_Array.set;
var _elm_lang$core$Array$get = F2(
	function (i, array) {
		return ((_elm_lang$core$Native_Utils.cmp(0, i) < 1) && (_elm_lang$core$Native_Utils.cmp(
			i,
			_elm_lang$core$Native_Array.length(array)) < 0)) ? _elm_lang$core$Maybe$Just(
			A2(_elm_lang$core$Native_Array.get, i, array)) : _elm_lang$core$Maybe$Nothing;
	});
var _elm_lang$core$Array$push = _elm_lang$core$Native_Array.push;
var _elm_lang$core$Array$empty = _elm_lang$core$Native_Array.empty;
var _elm_lang$core$Array$filter = F2(
	function (isOkay, arr) {
		var update = F2(
			function (x, xs) {
				return isOkay(x) ? A2(_elm_lang$core$Native_Array.push, x, xs) : xs;
			});
		return A3(_elm_lang$core$Native_Array.foldl, update, _elm_lang$core$Native_Array.empty, arr);
	});
var _elm_lang$core$Array$foldr = _elm_lang$core$Native_Array.foldr;
var _elm_lang$core$Array$foldl = _elm_lang$core$Native_Array.foldl;
var _elm_lang$core$Array$indexedMap = _elm_lang$core$Native_Array.indexedMap;
var _elm_lang$core$Array$map = _elm_lang$core$Native_Array.map;
var _elm_lang$core$Array$toIndexedList = function (array) {
	return A3(
		_elm_lang$core$List$map2,
		F2(
			function (v0, v1) {
				return {ctor: '_Tuple2', _0: v0, _1: v1};
			}),
		A2(
			_elm_lang$core$List$range,
			0,
			_elm_lang$core$Native_Array.length(array) - 1),
		_elm_lang$core$Native_Array.toList(array));
};
var _elm_lang$core$Array$toList = _elm_lang$core$Native_Array.toList;
var _elm_lang$core$Array$fromList = _elm_lang$core$Native_Array.fromList;
var _elm_lang$core$Array$initialize = _elm_lang$core$Native_Array.initialize;
var _elm_lang$core$Array$repeat = F2(
	function (n, e) {
		return A2(
			_elm_lang$core$Array$initialize,
			n,
			_elm_lang$core$Basics$always(e));
	});
var _elm_lang$core$Array$Array = {ctor: 'Array'};

//import Native.Utils //

var _elm_lang$core$Native_Debug = function() {

function log(tag, value)
{
	var msg = tag + ': ' + _elm_lang$core$Native_Utils.toString(value);
	var process = process || {};
	if (process.stdout)
	{
		process.stdout.write(msg);
	}
	else
	{
		console.log(msg);
	}
	return value;
}

function crash(message)
{
	throw new Error(message);
}

return {
	crash: crash,
	log: F2(log)
};

}();
//import Maybe, Native.List, Native.Utils, Result //

var _elm_lang$core$Native_String = function() {

function isEmpty(str)
{
	return str.length === 0;
}
function cons(chr, str)
{
	return chr + str;
}
function uncons(str)
{
	var hd = str[0];
	if (hd)
	{
		return _elm_lang$core$Maybe$Just(_elm_lang$core$Native_Utils.Tuple2(_elm_lang$core$Native_Utils.chr(hd), str.slice(1)));
	}
	return _elm_lang$core$Maybe$Nothing;
}
function append(a, b)
{
	return a + b;
}
function concat(strs)
{
	return _elm_lang$core$Native_List.toArray(strs).join('');
}
function length(str)
{
	return str.length;
}
function map(f, str)
{
	var out = str.split('');
	for (var i = out.length; i--; )
	{
		out[i] = f(_elm_lang$core$Native_Utils.chr(out[i]));
	}
	return out.join('');
}
function filter(pred, str)
{
	return str.split('').map(_elm_lang$core$Native_Utils.chr).filter(pred).join('');
}
function reverse(str)
{
	return str.split('').reverse().join('');
}
function foldl(f, b, str)
{
	var len = str.length;
	for (var i = 0; i < len; ++i)
	{
		b = A2(f, _elm_lang$core$Native_Utils.chr(str[i]), b);
	}
	return b;
}
function foldr(f, b, str)
{
	for (var i = str.length; i--; )
	{
		b = A2(f, _elm_lang$core$Native_Utils.chr(str[i]), b);
	}
	return b;
}
function split(sep, str)
{
	return _elm_lang$core$Native_List.fromArray(str.split(sep));
}
function join(sep, strs)
{
	return _elm_lang$core$Native_List.toArray(strs).join(sep);
}
function repeat(n, str)
{
	var result = '';
	while (n > 0)
	{
		if (n & 1)
		{
			result += str;
		}
		n >>= 1, str += str;
	}
	return result;
}
function slice(start, end, str)
{
	return str.slice(start, end);
}
function left(n, str)
{
	return n < 1 ? '' : str.slice(0, n);
}
function right(n, str)
{
	return n < 1 ? '' : str.slice(-n);
}
function dropLeft(n, str)
{
	return n < 1 ? str : str.slice(n);
}
function dropRight(n, str)
{
	return n < 1 ? str : str.slice(0, -n);
}
function pad(n, chr, str)
{
	var half = (n - str.length) / 2;
	return repeat(Math.ceil(half), chr) + str + repeat(half | 0, chr);
}
function padRight(n, chr, str)
{
	return str + repeat(n - str.length, chr);
}
function padLeft(n, chr, str)
{
	return repeat(n - str.length, chr) + str;
}

function trim(str)
{
	return str.trim();
}
function trimLeft(str)
{
	return str.replace(/^\s+/, '');
}
function trimRight(str)
{
	return str.replace(/\s+$/, '');
}

function words(str)
{
	return _elm_lang$core$Native_List.fromArray(str.trim().split(/\s+/g));
}
function lines(str)
{
	return _elm_lang$core$Native_List.fromArray(str.split(/\r\n|\r|\n/g));
}

function toUpper(str)
{
	return str.toUpperCase();
}
function toLower(str)
{
	return str.toLowerCase();
}

function any(pred, str)
{
	for (var i = str.length; i--; )
	{
		if (pred(_elm_lang$core$Native_Utils.chr(str[i])))
		{
			return true;
		}
	}
	return false;
}
function all(pred, str)
{
	for (var i = str.length; i--; )
	{
		if (!pred(_elm_lang$core$Native_Utils.chr(str[i])))
		{
			return false;
		}
	}
	return true;
}

function contains(sub, str)
{
	return str.indexOf(sub) > -1;
}
function startsWith(sub, str)
{
	return str.indexOf(sub) === 0;
}
function endsWith(sub, str)
{
	return str.length >= sub.length &&
		str.lastIndexOf(sub) === str.length - sub.length;
}
function indexes(sub, str)
{
	var subLen = sub.length;
	
	if (subLen < 1)
	{
		return _elm_lang$core$Native_List.Nil;
	}

	var i = 0;
	var is = [];

	while ((i = str.indexOf(sub, i)) > -1)
	{
		is.push(i);
		i = i + subLen;
	}	
	
	return _elm_lang$core$Native_List.fromArray(is);
}

function toInt(s)
{
	var len = s.length;
	if (len === 0)
	{
		return _elm_lang$core$Result$Err("could not convert string '" + s + "' to an Int" );
	}
	var start = 0;
	if (s[0] === '-')
	{
		if (len === 1)
		{
			return _elm_lang$core$Result$Err("could not convert string '" + s + "' to an Int" );
		}
		start = 1;
	}
	for (var i = start; i < len; ++i)
	{
		var c = s[i];
		if (c < '0' || '9' < c)
		{
			return _elm_lang$core$Result$Err("could not convert string '" + s + "' to an Int" );
		}
	}
	return _elm_lang$core$Result$Ok(parseInt(s, 10));
}

function toFloat(s)
{
	var len = s.length;
	if (len === 0)
	{
		return _elm_lang$core$Result$Err("could not convert string '" + s + "' to a Float" );
	}
	var start = 0;
	if (s[0] === '-')
	{
		if (len === 1)
		{
			return _elm_lang$core$Result$Err("could not convert string '" + s + "' to a Float" );
		}
		start = 1;
	}
	var dotCount = 0;
	for (var i = start; i < len; ++i)
	{
		var c = s[i];
		if ('0' <= c && c <= '9')
		{
			continue;
		}
		if (c === '.')
		{
			dotCount += 1;
			if (dotCount <= 1)
			{
				continue;
			}
		}
		return _elm_lang$core$Result$Err("could not convert string '" + s + "' to a Float" );
	}
	return _elm_lang$core$Result$Ok(parseFloat(s));
}

function toList(str)
{
	return _elm_lang$core$Native_List.fromArray(str.split('').map(_elm_lang$core$Native_Utils.chr));
}
function fromList(chars)
{
	return _elm_lang$core$Native_List.toArray(chars).join('');
}

return {
	isEmpty: isEmpty,
	cons: F2(cons),
	uncons: uncons,
	append: F2(append),
	concat: concat,
	length: length,
	map: F2(map),
	filter: F2(filter),
	reverse: reverse,
	foldl: F3(foldl),
	foldr: F3(foldr),

	split: F2(split),
	join: F2(join),
	repeat: F2(repeat),

	slice: F3(slice),
	left: F2(left),
	right: F2(right),
	dropLeft: F2(dropLeft),
	dropRight: F2(dropRight),

	pad: F3(pad),
	padLeft: F3(padLeft),
	padRight: F3(padRight),

	trim: trim,
	trimLeft: trimLeft,
	trimRight: trimRight,

	words: words,
	lines: lines,

	toUpper: toUpper,
	toLower: toLower,

	any: F2(any),
	all: F2(all),

	contains: F2(contains),
	startsWith: F2(startsWith),
	endsWith: F2(endsWith),
	indexes: F2(indexes),

	toInt: toInt,
	toFloat: toFloat,
	toList: toList,
	fromList: fromList
};

}();

//import Native.Utils //

var _elm_lang$core$Native_Char = function() {

return {
	fromCode: function(c) { return _elm_lang$core$Native_Utils.chr(String.fromCharCode(c)); },
	toCode: function(c) { return c.charCodeAt(0); },
	toUpper: function(c) { return _elm_lang$core$Native_Utils.chr(c.toUpperCase()); },
	toLower: function(c) { return _elm_lang$core$Native_Utils.chr(c.toLowerCase()); },
	toLocaleUpper: function(c) { return _elm_lang$core$Native_Utils.chr(c.toLocaleUpperCase()); },
	toLocaleLower: function(c) { return _elm_lang$core$Native_Utils.chr(c.toLocaleLowerCase()); }
};

}();
var _elm_lang$core$Char$fromCode = _elm_lang$core$Native_Char.fromCode;
var _elm_lang$core$Char$toCode = _elm_lang$core$Native_Char.toCode;
var _elm_lang$core$Char$toLocaleLower = _elm_lang$core$Native_Char.toLocaleLower;
var _elm_lang$core$Char$toLocaleUpper = _elm_lang$core$Native_Char.toLocaleUpper;
var _elm_lang$core$Char$toLower = _elm_lang$core$Native_Char.toLower;
var _elm_lang$core$Char$toUpper = _elm_lang$core$Native_Char.toUpper;
var _elm_lang$core$Char$isBetween = F3(
	function (low, high, $char) {
		var code = _elm_lang$core$Char$toCode($char);
		return (_elm_lang$core$Native_Utils.cmp(
			code,
			_elm_lang$core$Char$toCode(low)) > -1) && (_elm_lang$core$Native_Utils.cmp(
			code,
			_elm_lang$core$Char$toCode(high)) < 1);
	});
var _elm_lang$core$Char$isUpper = A2(
	_elm_lang$core$Char$isBetween,
	_elm_lang$core$Native_Utils.chr('A'),
	_elm_lang$core$Native_Utils.chr('Z'));
var _elm_lang$core$Char$isLower = A2(
	_elm_lang$core$Char$isBetween,
	_elm_lang$core$Native_Utils.chr('a'),
	_elm_lang$core$Native_Utils.chr('z'));
var _elm_lang$core$Char$isDigit = A2(
	_elm_lang$core$Char$isBetween,
	_elm_lang$core$Native_Utils.chr('0'),
	_elm_lang$core$Native_Utils.chr('9'));
var _elm_lang$core$Char$isOctDigit = A2(
	_elm_lang$core$Char$isBetween,
	_elm_lang$core$Native_Utils.chr('0'),
	_elm_lang$core$Native_Utils.chr('7'));
var _elm_lang$core$Char$isHexDigit = function ($char) {
	return _elm_lang$core$Char$isDigit($char) || (A3(
		_elm_lang$core$Char$isBetween,
		_elm_lang$core$Native_Utils.chr('a'),
		_elm_lang$core$Native_Utils.chr('f'),
		$char) || A3(
		_elm_lang$core$Char$isBetween,
		_elm_lang$core$Native_Utils.chr('A'),
		_elm_lang$core$Native_Utils.chr('F'),
		$char));
};

var _elm_lang$core$Result$toMaybe = function (result) {
	var _p0 = result;
	if (_p0.ctor === 'Ok') {
		return _elm_lang$core$Maybe$Just(_p0._0);
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _elm_lang$core$Result$withDefault = F2(
	function (def, result) {
		var _p1 = result;
		if (_p1.ctor === 'Ok') {
			return _p1._0;
		} else {
			return def;
		}
	});
var _elm_lang$core$Result$Err = function (a) {
	return {ctor: 'Err', _0: a};
};
var _elm_lang$core$Result$andThen = F2(
	function (callback, result) {
		var _p2 = result;
		if (_p2.ctor === 'Ok') {
			return callback(_p2._0);
		} else {
			return _elm_lang$core$Result$Err(_p2._0);
		}
	});
var _elm_lang$core$Result$Ok = function (a) {
	return {ctor: 'Ok', _0: a};
};
var _elm_lang$core$Result$map = F2(
	function (func, ra) {
		var _p3 = ra;
		if (_p3.ctor === 'Ok') {
			return _elm_lang$core$Result$Ok(
				func(_p3._0));
		} else {
			return _elm_lang$core$Result$Err(_p3._0);
		}
	});
var _elm_lang$core$Result$map2 = F3(
	function (func, ra, rb) {
		var _p4 = {ctor: '_Tuple2', _0: ra, _1: rb};
		if (_p4._0.ctor === 'Ok') {
			if (_p4._1.ctor === 'Ok') {
				return _elm_lang$core$Result$Ok(
					A2(func, _p4._0._0, _p4._1._0));
			} else {
				return _elm_lang$core$Result$Err(_p4._1._0);
			}
		} else {
			return _elm_lang$core$Result$Err(_p4._0._0);
		}
	});
var _elm_lang$core$Result$map3 = F4(
	function (func, ra, rb, rc) {
		var _p5 = {ctor: '_Tuple3', _0: ra, _1: rb, _2: rc};
		if (_p5._0.ctor === 'Ok') {
			if (_p5._1.ctor === 'Ok') {
				if (_p5._2.ctor === 'Ok') {
					return _elm_lang$core$Result$Ok(
						A3(func, _p5._0._0, _p5._1._0, _p5._2._0));
				} else {
					return _elm_lang$core$Result$Err(_p5._2._0);
				}
			} else {
				return _elm_lang$core$Result$Err(_p5._1._0);
			}
		} else {
			return _elm_lang$core$Result$Err(_p5._0._0);
		}
	});
var _elm_lang$core$Result$map4 = F5(
	function (func, ra, rb, rc, rd) {
		var _p6 = {ctor: '_Tuple4', _0: ra, _1: rb, _2: rc, _3: rd};
		if (_p6._0.ctor === 'Ok') {
			if (_p6._1.ctor === 'Ok') {
				if (_p6._2.ctor === 'Ok') {
					if (_p6._3.ctor === 'Ok') {
						return _elm_lang$core$Result$Ok(
							A4(func, _p6._0._0, _p6._1._0, _p6._2._0, _p6._3._0));
					} else {
						return _elm_lang$core$Result$Err(_p6._3._0);
					}
				} else {
					return _elm_lang$core$Result$Err(_p6._2._0);
				}
			} else {
				return _elm_lang$core$Result$Err(_p6._1._0);
			}
		} else {
			return _elm_lang$core$Result$Err(_p6._0._0);
		}
	});
var _elm_lang$core$Result$map5 = F6(
	function (func, ra, rb, rc, rd, re) {
		var _p7 = {ctor: '_Tuple5', _0: ra, _1: rb, _2: rc, _3: rd, _4: re};
		if (_p7._0.ctor === 'Ok') {
			if (_p7._1.ctor === 'Ok') {
				if (_p7._2.ctor === 'Ok') {
					if (_p7._3.ctor === 'Ok') {
						if (_p7._4.ctor === 'Ok') {
							return _elm_lang$core$Result$Ok(
								A5(func, _p7._0._0, _p7._1._0, _p7._2._0, _p7._3._0, _p7._4._0));
						} else {
							return _elm_lang$core$Result$Err(_p7._4._0);
						}
					} else {
						return _elm_lang$core$Result$Err(_p7._3._0);
					}
				} else {
					return _elm_lang$core$Result$Err(_p7._2._0);
				}
			} else {
				return _elm_lang$core$Result$Err(_p7._1._0);
			}
		} else {
			return _elm_lang$core$Result$Err(_p7._0._0);
		}
	});
var _elm_lang$core$Result$mapError = F2(
	function (f, result) {
		var _p8 = result;
		if (_p8.ctor === 'Ok') {
			return _elm_lang$core$Result$Ok(_p8._0);
		} else {
			return _elm_lang$core$Result$Err(
				f(_p8._0));
		}
	});
var _elm_lang$core$Result$fromMaybe = F2(
	function (err, maybe) {
		var _p9 = maybe;
		if (_p9.ctor === 'Just') {
			return _elm_lang$core$Result$Ok(_p9._0);
		} else {
			return _elm_lang$core$Result$Err(err);
		}
	});

var _elm_lang$core$String$fromList = _elm_lang$core$Native_String.fromList;
var _elm_lang$core$String$toList = _elm_lang$core$Native_String.toList;
var _elm_lang$core$String$toFloat = _elm_lang$core$Native_String.toFloat;
var _elm_lang$core$String$toInt = _elm_lang$core$Native_String.toInt;
var _elm_lang$core$String$indices = _elm_lang$core$Native_String.indexes;
var _elm_lang$core$String$indexes = _elm_lang$core$Native_String.indexes;
var _elm_lang$core$String$endsWith = _elm_lang$core$Native_String.endsWith;
var _elm_lang$core$String$startsWith = _elm_lang$core$Native_String.startsWith;
var _elm_lang$core$String$contains = _elm_lang$core$Native_String.contains;
var _elm_lang$core$String$all = _elm_lang$core$Native_String.all;
var _elm_lang$core$String$any = _elm_lang$core$Native_String.any;
var _elm_lang$core$String$toLower = _elm_lang$core$Native_String.toLower;
var _elm_lang$core$String$toUpper = _elm_lang$core$Native_String.toUpper;
var _elm_lang$core$String$lines = _elm_lang$core$Native_String.lines;
var _elm_lang$core$String$words = _elm_lang$core$Native_String.words;
var _elm_lang$core$String$trimRight = _elm_lang$core$Native_String.trimRight;
var _elm_lang$core$String$trimLeft = _elm_lang$core$Native_String.trimLeft;
var _elm_lang$core$String$trim = _elm_lang$core$Native_String.trim;
var _elm_lang$core$String$padRight = _elm_lang$core$Native_String.padRight;
var _elm_lang$core$String$padLeft = _elm_lang$core$Native_String.padLeft;
var _elm_lang$core$String$pad = _elm_lang$core$Native_String.pad;
var _elm_lang$core$String$dropRight = _elm_lang$core$Native_String.dropRight;
var _elm_lang$core$String$dropLeft = _elm_lang$core$Native_String.dropLeft;
var _elm_lang$core$String$right = _elm_lang$core$Native_String.right;
var _elm_lang$core$String$left = _elm_lang$core$Native_String.left;
var _elm_lang$core$String$slice = _elm_lang$core$Native_String.slice;
var _elm_lang$core$String$repeat = _elm_lang$core$Native_String.repeat;
var _elm_lang$core$String$join = _elm_lang$core$Native_String.join;
var _elm_lang$core$String$split = _elm_lang$core$Native_String.split;
var _elm_lang$core$String$foldr = _elm_lang$core$Native_String.foldr;
var _elm_lang$core$String$foldl = _elm_lang$core$Native_String.foldl;
var _elm_lang$core$String$reverse = _elm_lang$core$Native_String.reverse;
var _elm_lang$core$String$filter = _elm_lang$core$Native_String.filter;
var _elm_lang$core$String$map = _elm_lang$core$Native_String.map;
var _elm_lang$core$String$length = _elm_lang$core$Native_String.length;
var _elm_lang$core$String$concat = _elm_lang$core$Native_String.concat;
var _elm_lang$core$String$append = _elm_lang$core$Native_String.append;
var _elm_lang$core$String$uncons = _elm_lang$core$Native_String.uncons;
var _elm_lang$core$String$cons = _elm_lang$core$Native_String.cons;
var _elm_lang$core$String$fromChar = function ($char) {
	return A2(_elm_lang$core$String$cons, $char, '');
};
var _elm_lang$core$String$isEmpty = _elm_lang$core$Native_String.isEmpty;

var _elm_lang$core$Dict$foldr = F3(
	function (f, acc, t) {
		foldr:
		while (true) {
			var _p0 = t;
			if (_p0.ctor === 'RBEmpty_elm_builtin') {
				return acc;
			} else {
				var _v1 = f,
					_v2 = A3(
					f,
					_p0._1,
					_p0._2,
					A3(_elm_lang$core$Dict$foldr, f, acc, _p0._4)),
					_v3 = _p0._3;
				f = _v1;
				acc = _v2;
				t = _v3;
				continue foldr;
			}
		}
	});
var _elm_lang$core$Dict$keys = function (dict) {
	return A3(
		_elm_lang$core$Dict$foldr,
		F3(
			function (key, value, keyList) {
				return {ctor: '::', _0: key, _1: keyList};
			}),
		{ctor: '[]'},
		dict);
};
var _elm_lang$core$Dict$values = function (dict) {
	return A3(
		_elm_lang$core$Dict$foldr,
		F3(
			function (key, value, valueList) {
				return {ctor: '::', _0: value, _1: valueList};
			}),
		{ctor: '[]'},
		dict);
};
var _elm_lang$core$Dict$toList = function (dict) {
	return A3(
		_elm_lang$core$Dict$foldr,
		F3(
			function (key, value, list) {
				return {
					ctor: '::',
					_0: {ctor: '_Tuple2', _0: key, _1: value},
					_1: list
				};
			}),
		{ctor: '[]'},
		dict);
};
var _elm_lang$core$Dict$foldl = F3(
	function (f, acc, dict) {
		foldl:
		while (true) {
			var _p1 = dict;
			if (_p1.ctor === 'RBEmpty_elm_builtin') {
				return acc;
			} else {
				var _v5 = f,
					_v6 = A3(
					f,
					_p1._1,
					_p1._2,
					A3(_elm_lang$core$Dict$foldl, f, acc, _p1._3)),
					_v7 = _p1._4;
				f = _v5;
				acc = _v6;
				dict = _v7;
				continue foldl;
			}
		}
	});
var _elm_lang$core$Dict$merge = F6(
	function (leftStep, bothStep, rightStep, leftDict, rightDict, initialResult) {
		var stepState = F3(
			function (rKey, rValue, _p2) {
				stepState:
				while (true) {
					var _p3 = _p2;
					var _p9 = _p3._1;
					var _p8 = _p3._0;
					var _p4 = _p8;
					if (_p4.ctor === '[]') {
						return {
							ctor: '_Tuple2',
							_0: _p8,
							_1: A3(rightStep, rKey, rValue, _p9)
						};
					} else {
						var _p7 = _p4._1;
						var _p6 = _p4._0._1;
						var _p5 = _p4._0._0;
						if (_elm_lang$core$Native_Utils.cmp(_p5, rKey) < 0) {
							var _v10 = rKey,
								_v11 = rValue,
								_v12 = {
								ctor: '_Tuple2',
								_0: _p7,
								_1: A3(leftStep, _p5, _p6, _p9)
							};
							rKey = _v10;
							rValue = _v11;
							_p2 = _v12;
							continue stepState;
						} else {
							if (_elm_lang$core$Native_Utils.cmp(_p5, rKey) > 0) {
								return {
									ctor: '_Tuple2',
									_0: _p8,
									_1: A3(rightStep, rKey, rValue, _p9)
								};
							} else {
								return {
									ctor: '_Tuple2',
									_0: _p7,
									_1: A4(bothStep, _p5, _p6, rValue, _p9)
								};
							}
						}
					}
				}
			});
		var _p10 = A3(
			_elm_lang$core$Dict$foldl,
			stepState,
			{
				ctor: '_Tuple2',
				_0: _elm_lang$core$Dict$toList(leftDict),
				_1: initialResult
			},
			rightDict);
		var leftovers = _p10._0;
		var intermediateResult = _p10._1;
		return A3(
			_elm_lang$core$List$foldl,
			F2(
				function (_p11, result) {
					var _p12 = _p11;
					return A3(leftStep, _p12._0, _p12._1, result);
				}),
			intermediateResult,
			leftovers);
	});
var _elm_lang$core$Dict$reportRemBug = F4(
	function (msg, c, lgot, rgot) {
		return _elm_lang$core$Native_Debug.crash(
			_elm_lang$core$String$concat(
				{
					ctor: '::',
					_0: 'Internal red-black tree invariant violated, expected ',
					_1: {
						ctor: '::',
						_0: msg,
						_1: {
							ctor: '::',
							_0: ' and got ',
							_1: {
								ctor: '::',
								_0: _elm_lang$core$Basics$toString(c),
								_1: {
									ctor: '::',
									_0: '/',
									_1: {
										ctor: '::',
										_0: lgot,
										_1: {
											ctor: '::',
											_0: '/',
											_1: {
												ctor: '::',
												_0: rgot,
												_1: {
													ctor: '::',
													_0: '\nPlease report this bug to <https://github.com/elm-lang/core/issues>',
													_1: {ctor: '[]'}
												}
											}
										}
									}
								}
							}
						}
					}
				}));
	});
var _elm_lang$core$Dict$isBBlack = function (dict) {
	var _p13 = dict;
	_v14_2:
	do {
		if (_p13.ctor === 'RBNode_elm_builtin') {
			if (_p13._0.ctor === 'BBlack') {
				return true;
			} else {
				break _v14_2;
			}
		} else {
			if (_p13._0.ctor === 'LBBlack') {
				return true;
			} else {
				break _v14_2;
			}
		}
	} while(false);
	return false;
};
var _elm_lang$core$Dict$sizeHelp = F2(
	function (n, dict) {
		sizeHelp:
		while (true) {
			var _p14 = dict;
			if (_p14.ctor === 'RBEmpty_elm_builtin') {
				return n;
			} else {
				var _v16 = A2(_elm_lang$core$Dict$sizeHelp, n + 1, _p14._4),
					_v17 = _p14._3;
				n = _v16;
				dict = _v17;
				continue sizeHelp;
			}
		}
	});
var _elm_lang$core$Dict$size = function (dict) {
	return A2(_elm_lang$core$Dict$sizeHelp, 0, dict);
};
var _elm_lang$core$Dict$get = F2(
	function (targetKey, dict) {
		get:
		while (true) {
			var _p15 = dict;
			if (_p15.ctor === 'RBEmpty_elm_builtin') {
				return _elm_lang$core$Maybe$Nothing;
			} else {
				var _p16 = A2(_elm_lang$core$Basics$compare, targetKey, _p15._1);
				switch (_p16.ctor) {
					case 'LT':
						var _v20 = targetKey,
							_v21 = _p15._3;
						targetKey = _v20;
						dict = _v21;
						continue get;
					case 'EQ':
						return _elm_lang$core$Maybe$Just(_p15._2);
					default:
						var _v22 = targetKey,
							_v23 = _p15._4;
						targetKey = _v22;
						dict = _v23;
						continue get;
				}
			}
		}
	});
var _elm_lang$core$Dict$member = F2(
	function (key, dict) {
		var _p17 = A2(_elm_lang$core$Dict$get, key, dict);
		if (_p17.ctor === 'Just') {
			return true;
		} else {
			return false;
		}
	});
var _elm_lang$core$Dict$maxWithDefault = F3(
	function (k, v, r) {
		maxWithDefault:
		while (true) {
			var _p18 = r;
			if (_p18.ctor === 'RBEmpty_elm_builtin') {
				return {ctor: '_Tuple2', _0: k, _1: v};
			} else {
				var _v26 = _p18._1,
					_v27 = _p18._2,
					_v28 = _p18._4;
				k = _v26;
				v = _v27;
				r = _v28;
				continue maxWithDefault;
			}
		}
	});
var _elm_lang$core$Dict$NBlack = {ctor: 'NBlack'};
var _elm_lang$core$Dict$BBlack = {ctor: 'BBlack'};
var _elm_lang$core$Dict$Black = {ctor: 'Black'};
var _elm_lang$core$Dict$blackish = function (t) {
	var _p19 = t;
	if (_p19.ctor === 'RBNode_elm_builtin') {
		var _p20 = _p19._0;
		return _elm_lang$core$Native_Utils.eq(_p20, _elm_lang$core$Dict$Black) || _elm_lang$core$Native_Utils.eq(_p20, _elm_lang$core$Dict$BBlack);
	} else {
		return true;
	}
};
var _elm_lang$core$Dict$Red = {ctor: 'Red'};
var _elm_lang$core$Dict$moreBlack = function (color) {
	var _p21 = color;
	switch (_p21.ctor) {
		case 'Black':
			return _elm_lang$core$Dict$BBlack;
		case 'Red':
			return _elm_lang$core$Dict$Black;
		case 'NBlack':
			return _elm_lang$core$Dict$Red;
		default:
			return _elm_lang$core$Native_Debug.crash('Can\'t make a double black node more black!');
	}
};
var _elm_lang$core$Dict$lessBlack = function (color) {
	var _p22 = color;
	switch (_p22.ctor) {
		case 'BBlack':
			return _elm_lang$core$Dict$Black;
		case 'Black':
			return _elm_lang$core$Dict$Red;
		case 'Red':
			return _elm_lang$core$Dict$NBlack;
		default:
			return _elm_lang$core$Native_Debug.crash('Can\'t make a negative black node less black!');
	}
};
var _elm_lang$core$Dict$LBBlack = {ctor: 'LBBlack'};
var _elm_lang$core$Dict$LBlack = {ctor: 'LBlack'};
var _elm_lang$core$Dict$RBEmpty_elm_builtin = function (a) {
	return {ctor: 'RBEmpty_elm_builtin', _0: a};
};
var _elm_lang$core$Dict$empty = _elm_lang$core$Dict$RBEmpty_elm_builtin(_elm_lang$core$Dict$LBlack);
var _elm_lang$core$Dict$isEmpty = function (dict) {
	return _elm_lang$core$Native_Utils.eq(dict, _elm_lang$core$Dict$empty);
};
var _elm_lang$core$Dict$RBNode_elm_builtin = F5(
	function (a, b, c, d, e) {
		return {ctor: 'RBNode_elm_builtin', _0: a, _1: b, _2: c, _3: d, _4: e};
	});
var _elm_lang$core$Dict$ensureBlackRoot = function (dict) {
	var _p23 = dict;
	if ((_p23.ctor === 'RBNode_elm_builtin') && (_p23._0.ctor === 'Red')) {
		return A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, _p23._1, _p23._2, _p23._3, _p23._4);
	} else {
		return dict;
	}
};
var _elm_lang$core$Dict$lessBlackTree = function (dict) {
	var _p24 = dict;
	if (_p24.ctor === 'RBNode_elm_builtin') {
		return A5(
			_elm_lang$core$Dict$RBNode_elm_builtin,
			_elm_lang$core$Dict$lessBlack(_p24._0),
			_p24._1,
			_p24._2,
			_p24._3,
			_p24._4);
	} else {
		return _elm_lang$core$Dict$RBEmpty_elm_builtin(_elm_lang$core$Dict$LBlack);
	}
};
var _elm_lang$core$Dict$balancedTree = function (col) {
	return function (xk) {
		return function (xv) {
			return function (yk) {
				return function (yv) {
					return function (zk) {
						return function (zv) {
							return function (a) {
								return function (b) {
									return function (c) {
										return function (d) {
											return A5(
												_elm_lang$core$Dict$RBNode_elm_builtin,
												_elm_lang$core$Dict$lessBlack(col),
												yk,
												yv,
												A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, xk, xv, a, b),
												A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, zk, zv, c, d));
										};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};
var _elm_lang$core$Dict$blacken = function (t) {
	var _p25 = t;
	if (_p25.ctor === 'RBEmpty_elm_builtin') {
		return _elm_lang$core$Dict$RBEmpty_elm_builtin(_elm_lang$core$Dict$LBlack);
	} else {
		return A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, _p25._1, _p25._2, _p25._3, _p25._4);
	}
};
var _elm_lang$core$Dict$redden = function (t) {
	var _p26 = t;
	if (_p26.ctor === 'RBEmpty_elm_builtin') {
		return _elm_lang$core$Native_Debug.crash('can\'t make a Leaf red');
	} else {
		return A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Red, _p26._1, _p26._2, _p26._3, _p26._4);
	}
};
var _elm_lang$core$Dict$balanceHelp = function (tree) {
	var _p27 = tree;
	_v36_6:
	do {
		_v36_5:
		do {
			_v36_4:
			do {
				_v36_3:
				do {
					_v36_2:
					do {
						_v36_1:
						do {
							_v36_0:
							do {
								if (_p27.ctor === 'RBNode_elm_builtin') {
									if (_p27._3.ctor === 'RBNode_elm_builtin') {
										if (_p27._4.ctor === 'RBNode_elm_builtin') {
											switch (_p27._3._0.ctor) {
												case 'Red':
													switch (_p27._4._0.ctor) {
														case 'Red':
															if ((_p27._3._3.ctor === 'RBNode_elm_builtin') && (_p27._3._3._0.ctor === 'Red')) {
																break _v36_0;
															} else {
																if ((_p27._3._4.ctor === 'RBNode_elm_builtin') && (_p27._3._4._0.ctor === 'Red')) {
																	break _v36_1;
																} else {
																	if ((_p27._4._3.ctor === 'RBNode_elm_builtin') && (_p27._4._3._0.ctor === 'Red')) {
																		break _v36_2;
																	} else {
																		if ((_p27._4._4.ctor === 'RBNode_elm_builtin') && (_p27._4._4._0.ctor === 'Red')) {
																			break _v36_3;
																		} else {
																			break _v36_6;
																		}
																	}
																}
															}
														case 'NBlack':
															if ((_p27._3._3.ctor === 'RBNode_elm_builtin') && (_p27._3._3._0.ctor === 'Red')) {
																break _v36_0;
															} else {
																if ((_p27._3._4.ctor === 'RBNode_elm_builtin') && (_p27._3._4._0.ctor === 'Red')) {
																	break _v36_1;
																} else {
																	if (((((_p27._0.ctor === 'BBlack') && (_p27._4._3.ctor === 'RBNode_elm_builtin')) && (_p27._4._3._0.ctor === 'Black')) && (_p27._4._4.ctor === 'RBNode_elm_builtin')) && (_p27._4._4._0.ctor === 'Black')) {
																		break _v36_4;
																	} else {
																		break _v36_6;
																	}
																}
															}
														default:
															if ((_p27._3._3.ctor === 'RBNode_elm_builtin') && (_p27._3._3._0.ctor === 'Red')) {
																break _v36_0;
															} else {
																if ((_p27._3._4.ctor === 'RBNode_elm_builtin') && (_p27._3._4._0.ctor === 'Red')) {
																	break _v36_1;
																} else {
																	break _v36_6;
																}
															}
													}
												case 'NBlack':
													switch (_p27._4._0.ctor) {
														case 'Red':
															if ((_p27._4._3.ctor === 'RBNode_elm_builtin') && (_p27._4._3._0.ctor === 'Red')) {
																break _v36_2;
															} else {
																if ((_p27._4._4.ctor === 'RBNode_elm_builtin') && (_p27._4._4._0.ctor === 'Red')) {
																	break _v36_3;
																} else {
																	if (((((_p27._0.ctor === 'BBlack') && (_p27._3._3.ctor === 'RBNode_elm_builtin')) && (_p27._3._3._0.ctor === 'Black')) && (_p27._3._4.ctor === 'RBNode_elm_builtin')) && (_p27._3._4._0.ctor === 'Black')) {
																		break _v36_5;
																	} else {
																		break _v36_6;
																	}
																}
															}
														case 'NBlack':
															if (_p27._0.ctor === 'BBlack') {
																if ((((_p27._4._3.ctor === 'RBNode_elm_builtin') && (_p27._4._3._0.ctor === 'Black')) && (_p27._4._4.ctor === 'RBNode_elm_builtin')) && (_p27._4._4._0.ctor === 'Black')) {
																	break _v36_4;
																} else {
																	if ((((_p27._3._3.ctor === 'RBNode_elm_builtin') && (_p27._3._3._0.ctor === 'Black')) && (_p27._3._4.ctor === 'RBNode_elm_builtin')) && (_p27._3._4._0.ctor === 'Black')) {
																		break _v36_5;
																	} else {
																		break _v36_6;
																	}
																}
															} else {
																break _v36_6;
															}
														default:
															if (((((_p27._0.ctor === 'BBlack') && (_p27._3._3.ctor === 'RBNode_elm_builtin')) && (_p27._3._3._0.ctor === 'Black')) && (_p27._3._4.ctor === 'RBNode_elm_builtin')) && (_p27._3._4._0.ctor === 'Black')) {
																break _v36_5;
															} else {
																break _v36_6;
															}
													}
												default:
													switch (_p27._4._0.ctor) {
														case 'Red':
															if ((_p27._4._3.ctor === 'RBNode_elm_builtin') && (_p27._4._3._0.ctor === 'Red')) {
																break _v36_2;
															} else {
																if ((_p27._4._4.ctor === 'RBNode_elm_builtin') && (_p27._4._4._0.ctor === 'Red')) {
																	break _v36_3;
																} else {
																	break _v36_6;
																}
															}
														case 'NBlack':
															if (((((_p27._0.ctor === 'BBlack') && (_p27._4._3.ctor === 'RBNode_elm_builtin')) && (_p27._4._3._0.ctor === 'Black')) && (_p27._4._4.ctor === 'RBNode_elm_builtin')) && (_p27._4._4._0.ctor === 'Black')) {
																break _v36_4;
															} else {
																break _v36_6;
															}
														default:
															break _v36_6;
													}
											}
										} else {
											switch (_p27._3._0.ctor) {
												case 'Red':
													if ((_p27._3._3.ctor === 'RBNode_elm_builtin') && (_p27._3._3._0.ctor === 'Red')) {
														break _v36_0;
													} else {
														if ((_p27._3._4.ctor === 'RBNode_elm_builtin') && (_p27._3._4._0.ctor === 'Red')) {
															break _v36_1;
														} else {
															break _v36_6;
														}
													}
												case 'NBlack':
													if (((((_p27._0.ctor === 'BBlack') && (_p27._3._3.ctor === 'RBNode_elm_builtin')) && (_p27._3._3._0.ctor === 'Black')) && (_p27._3._4.ctor === 'RBNode_elm_builtin')) && (_p27._3._4._0.ctor === 'Black')) {
														break _v36_5;
													} else {
														break _v36_6;
													}
												default:
													break _v36_6;
											}
										}
									} else {
										if (_p27._4.ctor === 'RBNode_elm_builtin') {
											switch (_p27._4._0.ctor) {
												case 'Red':
													if ((_p27._4._3.ctor === 'RBNode_elm_builtin') && (_p27._4._3._0.ctor === 'Red')) {
														break _v36_2;
													} else {
														if ((_p27._4._4.ctor === 'RBNode_elm_builtin') && (_p27._4._4._0.ctor === 'Red')) {
															break _v36_3;
														} else {
															break _v36_6;
														}
													}
												case 'NBlack':
													if (((((_p27._0.ctor === 'BBlack') && (_p27._4._3.ctor === 'RBNode_elm_builtin')) && (_p27._4._3._0.ctor === 'Black')) && (_p27._4._4.ctor === 'RBNode_elm_builtin')) && (_p27._4._4._0.ctor === 'Black')) {
														break _v36_4;
													} else {
														break _v36_6;
													}
												default:
													break _v36_6;
											}
										} else {
											break _v36_6;
										}
									}
								} else {
									break _v36_6;
								}
							} while(false);
							return _elm_lang$core$Dict$balancedTree(_p27._0)(_p27._3._3._1)(_p27._3._3._2)(_p27._3._1)(_p27._3._2)(_p27._1)(_p27._2)(_p27._3._3._3)(_p27._3._3._4)(_p27._3._4)(_p27._4);
						} while(false);
						return _elm_lang$core$Dict$balancedTree(_p27._0)(_p27._3._1)(_p27._3._2)(_p27._3._4._1)(_p27._3._4._2)(_p27._1)(_p27._2)(_p27._3._3)(_p27._3._4._3)(_p27._3._4._4)(_p27._4);
					} while(false);
					return _elm_lang$core$Dict$balancedTree(_p27._0)(_p27._1)(_p27._2)(_p27._4._3._1)(_p27._4._3._2)(_p27._4._1)(_p27._4._2)(_p27._3)(_p27._4._3._3)(_p27._4._3._4)(_p27._4._4);
				} while(false);
				return _elm_lang$core$Dict$balancedTree(_p27._0)(_p27._1)(_p27._2)(_p27._4._1)(_p27._4._2)(_p27._4._4._1)(_p27._4._4._2)(_p27._3)(_p27._4._3)(_p27._4._4._3)(_p27._4._4._4);
			} while(false);
			return A5(
				_elm_lang$core$Dict$RBNode_elm_builtin,
				_elm_lang$core$Dict$Black,
				_p27._4._3._1,
				_p27._4._3._2,
				A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, _p27._1, _p27._2, _p27._3, _p27._4._3._3),
				A5(
					_elm_lang$core$Dict$balance,
					_elm_lang$core$Dict$Black,
					_p27._4._1,
					_p27._4._2,
					_p27._4._3._4,
					_elm_lang$core$Dict$redden(_p27._4._4)));
		} while(false);
		return A5(
			_elm_lang$core$Dict$RBNode_elm_builtin,
			_elm_lang$core$Dict$Black,
			_p27._3._4._1,
			_p27._3._4._2,
			A5(
				_elm_lang$core$Dict$balance,
				_elm_lang$core$Dict$Black,
				_p27._3._1,
				_p27._3._2,
				_elm_lang$core$Dict$redden(_p27._3._3),
				_p27._3._4._3),
			A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, _p27._1, _p27._2, _p27._3._4._4, _p27._4));
	} while(false);
	return tree;
};
var _elm_lang$core$Dict$balance = F5(
	function (c, k, v, l, r) {
		var tree = A5(_elm_lang$core$Dict$RBNode_elm_builtin, c, k, v, l, r);
		return _elm_lang$core$Dict$blackish(tree) ? _elm_lang$core$Dict$balanceHelp(tree) : tree;
	});
var _elm_lang$core$Dict$bubble = F5(
	function (c, k, v, l, r) {
		return (_elm_lang$core$Dict$isBBlack(l) || _elm_lang$core$Dict$isBBlack(r)) ? A5(
			_elm_lang$core$Dict$balance,
			_elm_lang$core$Dict$moreBlack(c),
			k,
			v,
			_elm_lang$core$Dict$lessBlackTree(l),
			_elm_lang$core$Dict$lessBlackTree(r)) : A5(_elm_lang$core$Dict$RBNode_elm_builtin, c, k, v, l, r);
	});
var _elm_lang$core$Dict$removeMax = F5(
	function (c, k, v, l, r) {
		var _p28 = r;
		if (_p28.ctor === 'RBEmpty_elm_builtin') {
			return A3(_elm_lang$core$Dict$rem, c, l, r);
		} else {
			return A5(
				_elm_lang$core$Dict$bubble,
				c,
				k,
				v,
				l,
				A5(_elm_lang$core$Dict$removeMax, _p28._0, _p28._1, _p28._2, _p28._3, _p28._4));
		}
	});
var _elm_lang$core$Dict$rem = F3(
	function (color, left, right) {
		var _p29 = {ctor: '_Tuple2', _0: left, _1: right};
		if (_p29._0.ctor === 'RBEmpty_elm_builtin') {
			if (_p29._1.ctor === 'RBEmpty_elm_builtin') {
				var _p30 = color;
				switch (_p30.ctor) {
					case 'Red':
						return _elm_lang$core$Dict$RBEmpty_elm_builtin(_elm_lang$core$Dict$LBlack);
					case 'Black':
						return _elm_lang$core$Dict$RBEmpty_elm_builtin(_elm_lang$core$Dict$LBBlack);
					default:
						return _elm_lang$core$Native_Debug.crash('cannot have bblack or nblack nodes at this point');
				}
			} else {
				var _p33 = _p29._1._0;
				var _p32 = _p29._0._0;
				var _p31 = {ctor: '_Tuple3', _0: color, _1: _p32, _2: _p33};
				if ((((_p31.ctor === '_Tuple3') && (_p31._0.ctor === 'Black')) && (_p31._1.ctor === 'LBlack')) && (_p31._2.ctor === 'Red')) {
					return A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, _p29._1._1, _p29._1._2, _p29._1._3, _p29._1._4);
				} else {
					return A4(
						_elm_lang$core$Dict$reportRemBug,
						'Black/LBlack/Red',
						color,
						_elm_lang$core$Basics$toString(_p32),
						_elm_lang$core$Basics$toString(_p33));
				}
			}
		} else {
			if (_p29._1.ctor === 'RBEmpty_elm_builtin') {
				var _p36 = _p29._1._0;
				var _p35 = _p29._0._0;
				var _p34 = {ctor: '_Tuple3', _0: color, _1: _p35, _2: _p36};
				if ((((_p34.ctor === '_Tuple3') && (_p34._0.ctor === 'Black')) && (_p34._1.ctor === 'Red')) && (_p34._2.ctor === 'LBlack')) {
					return A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, _p29._0._1, _p29._0._2, _p29._0._3, _p29._0._4);
				} else {
					return A4(
						_elm_lang$core$Dict$reportRemBug,
						'Black/Red/LBlack',
						color,
						_elm_lang$core$Basics$toString(_p35),
						_elm_lang$core$Basics$toString(_p36));
				}
			} else {
				var _p40 = _p29._0._2;
				var _p39 = _p29._0._4;
				var _p38 = _p29._0._1;
				var newLeft = A5(_elm_lang$core$Dict$removeMax, _p29._0._0, _p38, _p40, _p29._0._3, _p39);
				var _p37 = A3(_elm_lang$core$Dict$maxWithDefault, _p38, _p40, _p39);
				var k = _p37._0;
				var v = _p37._1;
				return A5(_elm_lang$core$Dict$bubble, color, k, v, newLeft, right);
			}
		}
	});
var _elm_lang$core$Dict$map = F2(
	function (f, dict) {
		var _p41 = dict;
		if (_p41.ctor === 'RBEmpty_elm_builtin') {
			return _elm_lang$core$Dict$RBEmpty_elm_builtin(_elm_lang$core$Dict$LBlack);
		} else {
			var _p42 = _p41._1;
			return A5(
				_elm_lang$core$Dict$RBNode_elm_builtin,
				_p41._0,
				_p42,
				A2(f, _p42, _p41._2),
				A2(_elm_lang$core$Dict$map, f, _p41._3),
				A2(_elm_lang$core$Dict$map, f, _p41._4));
		}
	});
var _elm_lang$core$Dict$Same = {ctor: 'Same'};
var _elm_lang$core$Dict$Remove = {ctor: 'Remove'};
var _elm_lang$core$Dict$Insert = {ctor: 'Insert'};
var _elm_lang$core$Dict$update = F3(
	function (k, alter, dict) {
		var up = function (dict) {
			var _p43 = dict;
			if (_p43.ctor === 'RBEmpty_elm_builtin') {
				var _p44 = alter(_elm_lang$core$Maybe$Nothing);
				if (_p44.ctor === 'Nothing') {
					return {ctor: '_Tuple2', _0: _elm_lang$core$Dict$Same, _1: _elm_lang$core$Dict$empty};
				} else {
					return {
						ctor: '_Tuple2',
						_0: _elm_lang$core$Dict$Insert,
						_1: A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Red, k, _p44._0, _elm_lang$core$Dict$empty, _elm_lang$core$Dict$empty)
					};
				}
			} else {
				var _p55 = _p43._2;
				var _p54 = _p43._4;
				var _p53 = _p43._3;
				var _p52 = _p43._1;
				var _p51 = _p43._0;
				var _p45 = A2(_elm_lang$core$Basics$compare, k, _p52);
				switch (_p45.ctor) {
					case 'EQ':
						var _p46 = alter(
							_elm_lang$core$Maybe$Just(_p55));
						if (_p46.ctor === 'Nothing') {
							return {
								ctor: '_Tuple2',
								_0: _elm_lang$core$Dict$Remove,
								_1: A3(_elm_lang$core$Dict$rem, _p51, _p53, _p54)
							};
						} else {
							return {
								ctor: '_Tuple2',
								_0: _elm_lang$core$Dict$Same,
								_1: A5(_elm_lang$core$Dict$RBNode_elm_builtin, _p51, _p52, _p46._0, _p53, _p54)
							};
						}
					case 'LT':
						var _p47 = up(_p53);
						var flag = _p47._0;
						var newLeft = _p47._1;
						var _p48 = flag;
						switch (_p48.ctor) {
							case 'Same':
								return {
									ctor: '_Tuple2',
									_0: _elm_lang$core$Dict$Same,
									_1: A5(_elm_lang$core$Dict$RBNode_elm_builtin, _p51, _p52, _p55, newLeft, _p54)
								};
							case 'Insert':
								return {
									ctor: '_Tuple2',
									_0: _elm_lang$core$Dict$Insert,
									_1: A5(_elm_lang$core$Dict$balance, _p51, _p52, _p55, newLeft, _p54)
								};
							default:
								return {
									ctor: '_Tuple2',
									_0: _elm_lang$core$Dict$Remove,
									_1: A5(_elm_lang$core$Dict$bubble, _p51, _p52, _p55, newLeft, _p54)
								};
						}
					default:
						var _p49 = up(_p54);
						var flag = _p49._0;
						var newRight = _p49._1;
						var _p50 = flag;
						switch (_p50.ctor) {
							case 'Same':
								return {
									ctor: '_Tuple2',
									_0: _elm_lang$core$Dict$Same,
									_1: A5(_elm_lang$core$Dict$RBNode_elm_builtin, _p51, _p52, _p55, _p53, newRight)
								};
							case 'Insert':
								return {
									ctor: '_Tuple2',
									_0: _elm_lang$core$Dict$Insert,
									_1: A5(_elm_lang$core$Dict$balance, _p51, _p52, _p55, _p53, newRight)
								};
							default:
								return {
									ctor: '_Tuple2',
									_0: _elm_lang$core$Dict$Remove,
									_1: A5(_elm_lang$core$Dict$bubble, _p51, _p52, _p55, _p53, newRight)
								};
						}
				}
			}
		};
		var _p56 = up(dict);
		var flag = _p56._0;
		var updatedDict = _p56._1;
		var _p57 = flag;
		switch (_p57.ctor) {
			case 'Same':
				return updatedDict;
			case 'Insert':
				return _elm_lang$core$Dict$ensureBlackRoot(updatedDict);
			default:
				return _elm_lang$core$Dict$blacken(updatedDict);
		}
	});
var _elm_lang$core$Dict$insert = F3(
	function (key, value, dict) {
		return A3(
			_elm_lang$core$Dict$update,
			key,
			_elm_lang$core$Basics$always(
				_elm_lang$core$Maybe$Just(value)),
			dict);
	});
var _elm_lang$core$Dict$singleton = F2(
	function (key, value) {
		return A3(_elm_lang$core$Dict$insert, key, value, _elm_lang$core$Dict$empty);
	});
var _elm_lang$core$Dict$union = F2(
	function (t1, t2) {
		return A3(_elm_lang$core$Dict$foldl, _elm_lang$core$Dict$insert, t2, t1);
	});
var _elm_lang$core$Dict$filter = F2(
	function (predicate, dictionary) {
		var add = F3(
			function (key, value, dict) {
				return A2(predicate, key, value) ? A3(_elm_lang$core$Dict$insert, key, value, dict) : dict;
			});
		return A3(_elm_lang$core$Dict$foldl, add, _elm_lang$core$Dict$empty, dictionary);
	});
var _elm_lang$core$Dict$intersect = F2(
	function (t1, t2) {
		return A2(
			_elm_lang$core$Dict$filter,
			F2(
				function (k, _p58) {
					return A2(_elm_lang$core$Dict$member, k, t2);
				}),
			t1);
	});
var _elm_lang$core$Dict$partition = F2(
	function (predicate, dict) {
		var add = F3(
			function (key, value, _p59) {
				var _p60 = _p59;
				var _p62 = _p60._1;
				var _p61 = _p60._0;
				return A2(predicate, key, value) ? {
					ctor: '_Tuple2',
					_0: A3(_elm_lang$core$Dict$insert, key, value, _p61),
					_1: _p62
				} : {
					ctor: '_Tuple2',
					_0: _p61,
					_1: A3(_elm_lang$core$Dict$insert, key, value, _p62)
				};
			});
		return A3(
			_elm_lang$core$Dict$foldl,
			add,
			{ctor: '_Tuple2', _0: _elm_lang$core$Dict$empty, _1: _elm_lang$core$Dict$empty},
			dict);
	});
var _elm_lang$core$Dict$fromList = function (assocs) {
	return A3(
		_elm_lang$core$List$foldl,
		F2(
			function (_p63, dict) {
				var _p64 = _p63;
				return A3(_elm_lang$core$Dict$insert, _p64._0, _p64._1, dict);
			}),
		_elm_lang$core$Dict$empty,
		assocs);
};
var _elm_lang$core$Dict$remove = F2(
	function (key, dict) {
		return A3(
			_elm_lang$core$Dict$update,
			key,
			_elm_lang$core$Basics$always(_elm_lang$core$Maybe$Nothing),
			dict);
	});
var _elm_lang$core$Dict$diff = F2(
	function (t1, t2) {
		return A3(
			_elm_lang$core$Dict$foldl,
			F3(
				function (k, v, t) {
					return A2(_elm_lang$core$Dict$remove, k, t);
				}),
			t1,
			t2);
	});

var _elm_lang$core$Debug$crash = _elm_lang$core$Native_Debug.crash;
var _elm_lang$core$Debug$log = _elm_lang$core$Native_Debug.log;

var _elm_lang$core$Tuple$mapSecond = F2(
	function (func, _p0) {
		var _p1 = _p0;
		return {
			ctor: '_Tuple2',
			_0: _p1._0,
			_1: func(_p1._1)
		};
	});
var _elm_lang$core$Tuple$mapFirst = F2(
	function (func, _p2) {
		var _p3 = _p2;
		return {
			ctor: '_Tuple2',
			_0: func(_p3._0),
			_1: _p3._1
		};
	});
var _elm_lang$core$Tuple$second = function (_p4) {
	var _p5 = _p4;
	return _p5._1;
};
var _elm_lang$core$Tuple$first = function (_p6) {
	var _p7 = _p6;
	return _p7._0;
};

//import //

var _elm_lang$core$Native_Platform = function() {


// PROGRAMS

function program(impl)
{
	return function(flagDecoder)
	{
		return function(object, moduleName)
		{
			object['worker'] = function worker(flags)
			{
				if (typeof flags !== 'undefined')
				{
					throw new Error(
						'The `' + moduleName + '` module does not need flags.\n'
						+ 'Call ' + moduleName + '.worker() with no arguments and you should be all set!'
					);
				}

				return initialize(
					impl.init,
					impl.update,
					impl.subscriptions,
					renderer
				);
			};
		};
	};
}

function programWithFlags(impl)
{
	return function(flagDecoder)
	{
		return function(object, moduleName)
		{
			object['worker'] = function worker(flags)
			{
				if (typeof flagDecoder === 'undefined')
				{
					throw new Error(
						'Are you trying to sneak a Never value into Elm? Trickster!\n'
						+ 'It looks like ' + moduleName + '.main is defined with `programWithFlags` but has type `Program Never`.\n'
						+ 'Use `program` instead if you do not want flags.'
					);
				}

				var result = A2(_elm_lang$core$Native_Json.run, flagDecoder, flags);
				if (result.ctor === 'Err')
				{
					throw new Error(
						moduleName + '.worker(...) was called with an unexpected argument.\n'
						+ 'I tried to convert it to an Elm value, but ran into this problem:\n\n'
						+ result._0
					);
				}

				return initialize(
					impl.init(result._0),
					impl.update,
					impl.subscriptions,
					renderer
				);
			};
		};
	};
}

function renderer(enqueue, _)
{
	return function(_) {};
}


// HTML TO PROGRAM

function htmlToProgram(vnode)
{
	var emptyBag = batch(_elm_lang$core$Native_List.Nil);
	var noChange = _elm_lang$core$Native_Utils.Tuple2(
		_elm_lang$core$Native_Utils.Tuple0,
		emptyBag
	);

	return _elm_lang$virtual_dom$VirtualDom$program({
		init: noChange,
		view: function(model) { return main; },
		update: F2(function(msg, model) { return noChange; }),
		subscriptions: function (model) { return emptyBag; }
	});
}


// INITIALIZE A PROGRAM

function initialize(init, update, subscriptions, renderer)
{
	// ambient state
	var managers = {};
	var updateView;

	// init and update state in main process
	var initApp = _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
		var model = init._0;
		updateView = renderer(enqueue, model);
		var cmds = init._1;
		var subs = subscriptions(model);
		dispatchEffects(managers, cmds, subs);
		callback(_elm_lang$core$Native_Scheduler.succeed(model));
	});

	function onMessage(msg, model)
	{
		return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
			var results = A2(update, msg, model);
			model = results._0;
			updateView(model);
			var cmds = results._1;
			var subs = subscriptions(model);
			dispatchEffects(managers, cmds, subs);
			callback(_elm_lang$core$Native_Scheduler.succeed(model));
		});
	}

	var mainProcess = spawnLoop(initApp, onMessage);

	function enqueue(msg)
	{
		_elm_lang$core$Native_Scheduler.rawSend(mainProcess, msg);
	}

	var ports = setupEffects(managers, enqueue);

	return ports ? { ports: ports } : {};
}


// EFFECT MANAGERS

var effectManagers = {};

function setupEffects(managers, callback)
{
	var ports;

	// setup all necessary effect managers
	for (var key in effectManagers)
	{
		var manager = effectManagers[key];

		if (manager.isForeign)
		{
			ports = ports || {};
			ports[key] = manager.tag === 'cmd'
				? setupOutgoingPort(key)
				: setupIncomingPort(key, callback);
		}

		managers[key] = makeManager(manager, callback);
	}

	return ports;
}

function makeManager(info, callback)
{
	var router = {
		main: callback,
		self: undefined
	};

	var tag = info.tag;
	var onEffects = info.onEffects;
	var onSelfMsg = info.onSelfMsg;

	function onMessage(msg, state)
	{
		if (msg.ctor === 'self')
		{
			return A3(onSelfMsg, router, msg._0, state);
		}

		var fx = msg._0;
		switch (tag)
		{
			case 'cmd':
				return A3(onEffects, router, fx.cmds, state);

			case 'sub':
				return A3(onEffects, router, fx.subs, state);

			case 'fx':
				return A4(onEffects, router, fx.cmds, fx.subs, state);
		}
	}

	var process = spawnLoop(info.init, onMessage);
	router.self = process;
	return process;
}

function sendToApp(router, msg)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		router.main(msg);
		callback(_elm_lang$core$Native_Scheduler.succeed(_elm_lang$core$Native_Utils.Tuple0));
	});
}

function sendToSelf(router, msg)
{
	return A2(_elm_lang$core$Native_Scheduler.send, router.self, {
		ctor: 'self',
		_0: msg
	});
}


// HELPER for STATEFUL LOOPS

function spawnLoop(init, onMessage)
{
	var andThen = _elm_lang$core$Native_Scheduler.andThen;

	function loop(state)
	{
		var handleMsg = _elm_lang$core$Native_Scheduler.receive(function(msg) {
			return onMessage(msg, state);
		});
		return A2(andThen, loop, handleMsg);
	}

	var task = A2(andThen, loop, init);

	return _elm_lang$core$Native_Scheduler.rawSpawn(task);
}


// BAGS

function leaf(home)
{
	return function(value)
	{
		return {
			type: 'leaf',
			home: home,
			value: value
		};
	};
}

function batch(list)
{
	return {
		type: 'node',
		branches: list
	};
}

function map(tagger, bag)
{
	return {
		type: 'map',
		tagger: tagger,
		tree: bag
	}
}


// PIPE BAGS INTO EFFECT MANAGERS

function dispatchEffects(managers, cmdBag, subBag)
{
	var effectsDict = {};
	gatherEffects(true, cmdBag, effectsDict, null);
	gatherEffects(false, subBag, effectsDict, null);

	for (var home in managers)
	{
		var fx = home in effectsDict
			? effectsDict[home]
			: {
				cmds: _elm_lang$core$Native_List.Nil,
				subs: _elm_lang$core$Native_List.Nil
			};

		_elm_lang$core$Native_Scheduler.rawSend(managers[home], { ctor: 'fx', _0: fx });
	}
}

function gatherEffects(isCmd, bag, effectsDict, taggers)
{
	switch (bag.type)
	{
		case 'leaf':
			var home = bag.home;
			var effect = toEffect(isCmd, home, taggers, bag.value);
			effectsDict[home] = insert(isCmd, effect, effectsDict[home]);
			return;

		case 'node':
			var list = bag.branches;
			while (list.ctor !== '[]')
			{
				gatherEffects(isCmd, list._0, effectsDict, taggers);
				list = list._1;
			}
			return;

		case 'map':
			gatherEffects(isCmd, bag.tree, effectsDict, {
				tagger: bag.tagger,
				rest: taggers
			});
			return;
	}
}

function toEffect(isCmd, home, taggers, value)
{
	function applyTaggers(x)
	{
		var temp = taggers;
		while (temp)
		{
			x = temp.tagger(x);
			temp = temp.rest;
		}
		return x;
	}

	var map = isCmd
		? effectManagers[home].cmdMap
		: effectManagers[home].subMap;

	return A2(map, applyTaggers, value)
}

function insert(isCmd, newEffect, effects)
{
	effects = effects || {
		cmds: _elm_lang$core$Native_List.Nil,
		subs: _elm_lang$core$Native_List.Nil
	};
	if (isCmd)
	{
		effects.cmds = _elm_lang$core$Native_List.Cons(newEffect, effects.cmds);
		return effects;
	}
	effects.subs = _elm_lang$core$Native_List.Cons(newEffect, effects.subs);
	return effects;
}


// PORTS

function checkPortName(name)
{
	if (name in effectManagers)
	{
		throw new Error('There can only be one port named `' + name + '`, but your program has multiple.');
	}
}


// OUTGOING PORTS

function outgoingPort(name, converter)
{
	checkPortName(name);
	effectManagers[name] = {
		tag: 'cmd',
		cmdMap: outgoingPortMap,
		converter: converter,
		isForeign: true
	};
	return leaf(name);
}

var outgoingPortMap = F2(function cmdMap(tagger, value) {
	return value;
});

function setupOutgoingPort(name)
{
	var subs = [];
	var converter = effectManagers[name].converter;

	// CREATE MANAGER

	var init = _elm_lang$core$Native_Scheduler.succeed(null);

	function onEffects(router, cmdList, state)
	{
		while (cmdList.ctor !== '[]')
		{
			// grab a separate reference to subs in case unsubscribe is called
			var currentSubs = subs;
			var value = converter(cmdList._0);
			for (var i = 0; i < currentSubs.length; i++)
			{
				currentSubs[i](value);
			}
			cmdList = cmdList._1;
		}
		return init;
	}

	effectManagers[name].init = init;
	effectManagers[name].onEffects = F3(onEffects);

	// PUBLIC API

	function subscribe(callback)
	{
		subs.push(callback);
	}

	function unsubscribe(callback)
	{
		// copy subs into a new array in case unsubscribe is called within a
		// subscribed callback
		subs = subs.slice();
		var index = subs.indexOf(callback);
		if (index >= 0)
		{
			subs.splice(index, 1);
		}
	}

	return {
		subscribe: subscribe,
		unsubscribe: unsubscribe
	};
}


// INCOMING PORTS

function incomingPort(name, converter)
{
	checkPortName(name);
	effectManagers[name] = {
		tag: 'sub',
		subMap: incomingPortMap,
		converter: converter,
		isForeign: true
	};
	return leaf(name);
}

var incomingPortMap = F2(function subMap(tagger, finalTagger)
{
	return function(value)
	{
		return tagger(finalTagger(value));
	};
});

function setupIncomingPort(name, callback)
{
	var sentBeforeInit = [];
	var subs = _elm_lang$core$Native_List.Nil;
	var converter = effectManagers[name].converter;
	var currentOnEffects = preInitOnEffects;
	var currentSend = preInitSend;

	// CREATE MANAGER

	var init = _elm_lang$core$Native_Scheduler.succeed(null);

	function preInitOnEffects(router, subList, state)
	{
		var postInitResult = postInitOnEffects(router, subList, state);

		for(var i = 0; i < sentBeforeInit.length; i++)
		{
			postInitSend(sentBeforeInit[i]);
		}

		sentBeforeInit = null; // to release objects held in queue
		currentSend = postInitSend;
		currentOnEffects = postInitOnEffects;
		return postInitResult;
	}

	function postInitOnEffects(router, subList, state)
	{
		subs = subList;
		return init;
	}

	function onEffects(router, subList, state)
	{
		return currentOnEffects(router, subList, state);
	}

	effectManagers[name].init = init;
	effectManagers[name].onEffects = F3(onEffects);

	// PUBLIC API

	function preInitSend(value)
	{
		sentBeforeInit.push(value);
	}

	function postInitSend(incomingValue)
	{
		var result = A2(_elm_lang$core$Json_Decode$decodeValue, converter, incomingValue);
		if (result.ctor === 'Err')
		{
			throw new Error('Trying to send an unexpected type of value through port `' + name + '`:\n' + result._0);
		}

		var value = result._0;
		var temp = subs;
		while (temp.ctor !== '[]')
		{
			callback(temp._0(value));
			temp = temp._1;
		}
	}

	function send(incomingValue)
	{
		currentSend(incomingValue);
	}

	return { send: send };
}

return {
	// routers
	sendToApp: F2(sendToApp),
	sendToSelf: F2(sendToSelf),

	// global setup
	effectManagers: effectManagers,
	outgoingPort: outgoingPort,
	incomingPort: incomingPort,

	htmlToProgram: htmlToProgram,
	program: program,
	programWithFlags: programWithFlags,
	initialize: initialize,

	// effect bags
	leaf: leaf,
	batch: batch,
	map: F2(map)
};

}();

//import Native.Utils //

var _elm_lang$core$Native_Scheduler = function() {

var MAX_STEPS = 10000;


// TASKS

function succeed(value)
{
	return {
		ctor: '_Task_succeed',
		value: value
	};
}

function fail(error)
{
	return {
		ctor: '_Task_fail',
		value: error
	};
}

function nativeBinding(callback)
{
	return {
		ctor: '_Task_nativeBinding',
		callback: callback,
		cancel: null
	};
}

function andThen(callback, task)
{
	return {
		ctor: '_Task_andThen',
		callback: callback,
		task: task
	};
}

function onError(callback, task)
{
	return {
		ctor: '_Task_onError',
		callback: callback,
		task: task
	};
}

function receive(callback)
{
	return {
		ctor: '_Task_receive',
		callback: callback
	};
}


// PROCESSES

function rawSpawn(task)
{
	var process = {
		ctor: '_Process',
		id: _elm_lang$core$Native_Utils.guid(),
		root: task,
		stack: null,
		mailbox: []
	};

	enqueue(process);

	return process;
}

function spawn(task)
{
	return nativeBinding(function(callback) {
		var process = rawSpawn(task);
		callback(succeed(process));
	});
}

function rawSend(process, msg)
{
	process.mailbox.push(msg);
	enqueue(process);
}

function send(process, msg)
{
	return nativeBinding(function(callback) {
		rawSend(process, msg);
		callback(succeed(_elm_lang$core$Native_Utils.Tuple0));
	});
}

function kill(process)
{
	return nativeBinding(function(callback) {
		var root = process.root;
		if (root.ctor === '_Task_nativeBinding' && root.cancel)
		{
			root.cancel();
		}

		process.root = null;

		callback(succeed(_elm_lang$core$Native_Utils.Tuple0));
	});
}

function sleep(time)
{
	return nativeBinding(function(callback) {
		var id = setTimeout(function() {
			callback(succeed(_elm_lang$core$Native_Utils.Tuple0));
		}, time);

		return function() { clearTimeout(id); };
	});
}


// STEP PROCESSES

function step(numSteps, process)
{
	while (numSteps < MAX_STEPS)
	{
		var ctor = process.root.ctor;

		if (ctor === '_Task_succeed')
		{
			while (process.stack && process.stack.ctor === '_Task_onError')
			{
				process.stack = process.stack.rest;
			}
			if (process.stack === null)
			{
				break;
			}
			process.root = process.stack.callback(process.root.value);
			process.stack = process.stack.rest;
			++numSteps;
			continue;
		}

		if (ctor === '_Task_fail')
		{
			while (process.stack && process.stack.ctor === '_Task_andThen')
			{
				process.stack = process.stack.rest;
			}
			if (process.stack === null)
			{
				break;
			}
			process.root = process.stack.callback(process.root.value);
			process.stack = process.stack.rest;
			++numSteps;
			continue;
		}

		if (ctor === '_Task_andThen')
		{
			process.stack = {
				ctor: '_Task_andThen',
				callback: process.root.callback,
				rest: process.stack
			};
			process.root = process.root.task;
			++numSteps;
			continue;
		}

		if (ctor === '_Task_onError')
		{
			process.stack = {
				ctor: '_Task_onError',
				callback: process.root.callback,
				rest: process.stack
			};
			process.root = process.root.task;
			++numSteps;
			continue;
		}

		if (ctor === '_Task_nativeBinding')
		{
			process.root.cancel = process.root.callback(function(newRoot) {
				process.root = newRoot;
				enqueue(process);
			});

			break;
		}

		if (ctor === '_Task_receive')
		{
			var mailbox = process.mailbox;
			if (mailbox.length === 0)
			{
				break;
			}

			process.root = process.root.callback(mailbox.shift());
			++numSteps;
			continue;
		}

		throw new Error(ctor);
	}

	if (numSteps < MAX_STEPS)
	{
		return numSteps + 1;
	}
	enqueue(process);

	return numSteps;
}


// WORK QUEUE

var working = false;
var workQueue = [];

function enqueue(process)
{
	workQueue.push(process);

	if (!working)
	{
		setTimeout(work, 0);
		working = true;
	}
}

function work()
{
	var numSteps = 0;
	var process;
	while (numSteps < MAX_STEPS && (process = workQueue.shift()))
	{
		if (process.root)
		{
			numSteps = step(numSteps, process);
		}
	}
	if (!process)
	{
		working = false;
		return;
	}
	setTimeout(work, 0);
}


return {
	succeed: succeed,
	fail: fail,
	nativeBinding: nativeBinding,
	andThen: F2(andThen),
	onError: F2(onError),
	receive: receive,

	spawn: spawn,
	kill: kill,
	sleep: sleep,
	send: F2(send),

	rawSpawn: rawSpawn,
	rawSend: rawSend
};

}();
var _elm_lang$core$Platform_Cmd$batch = _elm_lang$core$Native_Platform.batch;
var _elm_lang$core$Platform_Cmd$none = _elm_lang$core$Platform_Cmd$batch(
	{ctor: '[]'});
var _elm_lang$core$Platform_Cmd_ops = _elm_lang$core$Platform_Cmd_ops || {};
_elm_lang$core$Platform_Cmd_ops['!'] = F2(
	function (model, commands) {
		return {
			ctor: '_Tuple2',
			_0: model,
			_1: _elm_lang$core$Platform_Cmd$batch(commands)
		};
	});
var _elm_lang$core$Platform_Cmd$map = _elm_lang$core$Native_Platform.map;
var _elm_lang$core$Platform_Cmd$Cmd = {ctor: 'Cmd'};

var _elm_lang$core$Platform_Sub$batch = _elm_lang$core$Native_Platform.batch;
var _elm_lang$core$Platform_Sub$none = _elm_lang$core$Platform_Sub$batch(
	{ctor: '[]'});
var _elm_lang$core$Platform_Sub$map = _elm_lang$core$Native_Platform.map;
var _elm_lang$core$Platform_Sub$Sub = {ctor: 'Sub'};

var _elm_lang$core$Platform$hack = _elm_lang$core$Native_Scheduler.succeed;
var _elm_lang$core$Platform$sendToSelf = _elm_lang$core$Native_Platform.sendToSelf;
var _elm_lang$core$Platform$sendToApp = _elm_lang$core$Native_Platform.sendToApp;
var _elm_lang$core$Platform$programWithFlags = _elm_lang$core$Native_Platform.programWithFlags;
var _elm_lang$core$Platform$program = _elm_lang$core$Native_Platform.program;
var _elm_lang$core$Platform$Program = {ctor: 'Program'};
var _elm_lang$core$Platform$Task = {ctor: 'Task'};
var _elm_lang$core$Platform$ProcessId = {ctor: 'ProcessId'};
var _elm_lang$core$Platform$Router = {ctor: 'Router'};

var _arturopala$elm_monocle$Monocle_Iso$modify = F2(
	function (iso, f) {
		return function (_p0) {
			return iso.reverseGet(
				f(
					iso.get(_p0)));
		};
	});
var _arturopala$elm_monocle$Monocle_Iso$Iso = F2(
	function (a, b) {
		return {get: a, reverseGet: b};
	});
var _arturopala$elm_monocle$Monocle_Iso$reverse = function (iso) {
	return A2(_arturopala$elm_monocle$Monocle_Iso$Iso, iso.reverseGet, iso.get);
};
var _arturopala$elm_monocle$Monocle_Iso$compose = F2(
	function (outer, inner) {
		return A2(
			_arturopala$elm_monocle$Monocle_Iso$Iso,
			function (_p1) {
				return inner.get(
					outer.get(_p1));
			},
			function (_p2) {
				return outer.reverseGet(
					inner.reverseGet(_p2));
			});
	});

var _arturopala$elm_monocle$Monocle_Lens$modifyAndMerge = F3(
	function (lens, fx, merge) {
		var mf = function (_p0) {
			var _p1 = _p0;
			var _p4 = _p1._0;
			return function (_p2) {
				var _p3 = _p2;
				return {
					ctor: '_Tuple2',
					_0: A2(lens.set, _p3._0, _p4),
					_1: A2(merge, _p1._1, _p3._1)
				};
			}(
				fx(
					lens.get(_p4)));
		};
		return mf;
	});
var _arturopala$elm_monocle$Monocle_Lens$modify3 = F4(
	function (lens1, lens2, lens3, fx) {
		var mf = function (_p5) {
			var _p6 = _p5;
			var _p11 = _p6._2;
			var _p10 = _p6._1;
			var _p9 = _p6._0;
			return function (_p7) {
				var _p8 = _p7;
				return {
					ctor: '_Tuple3',
					_0: A2(lens1.set, _p8._0, _p9),
					_1: A2(lens2.set, _p8._1, _p10),
					_2: A2(lens3.set, _p8._2, _p11)
				};
			}(
				fx(
					{
						ctor: '_Tuple3',
						_0: lens1.get(_p9),
						_1: lens2.get(_p10),
						_2: lens3.get(_p11)
					}));
		};
		return mf;
	});
var _arturopala$elm_monocle$Monocle_Lens$modify2 = F3(
	function (lens1, lens2, fx) {
		var mf = function (_p12) {
			var _p13 = _p12;
			var _p17 = _p13._1;
			var _p16 = _p13._0;
			return function (_p14) {
				var _p15 = _p14;
				return {
					ctor: '_Tuple2',
					_0: A2(lens1.set, _p15._0, _p16),
					_1: A2(lens2.set, _p15._1, _p17)
				};
			}(
				fx(
					{
						ctor: '_Tuple2',
						_0: lens1.get(_p16),
						_1: lens2.get(_p17)
					}));
		};
		return mf;
	});
var _arturopala$elm_monocle$Monocle_Lens$modify = F2(
	function (lens, f) {
		var mf = function (a) {
			return function (b) {
				return A2(lens.set, b, a);
			}(
				f(
					lens.get(a)));
		};
		return mf;
	});
var _arturopala$elm_monocle$Monocle_Lens$Lens = F2(
	function (a, b) {
		return {get: a, set: b};
	});
var _arturopala$elm_monocle$Monocle_Lens$compose = F2(
	function (outer, inner) {
		var set = F2(
			function (c, a) {
				return function (b) {
					return A2(outer.set, b, a);
				}(
					A2(
						inner.set,
						c,
						outer.get(a)));
			});
		return A2(
			_arturopala$elm_monocle$Monocle_Lens$Lens,
			function (_p18) {
				return inner.get(
					outer.get(_p18));
			},
			set);
	});
var _arturopala$elm_monocle$Monocle_Lens$fromIso = function (iso) {
	var set = F2(
		function (b, _p19) {
			return iso.reverseGet(b);
		});
	return A2(_arturopala$elm_monocle$Monocle_Lens$Lens, iso.get, set);
};
var _arturopala$elm_monocle$Monocle_Lens$zip = F2(
	function (left, right) {
		var set = F2(
			function (_p21, _p20) {
				var _p22 = _p21;
				var _p23 = _p20;
				return {
					ctor: '_Tuple2',
					_0: A2(left.set, _p22._0, _p23._0),
					_1: A2(right.set, _p22._1, _p23._1)
				};
			});
		var get = function (_p24) {
			var _p25 = _p24;
			return {
				ctor: '_Tuple2',
				_0: left.get(_p25._0),
				_1: right.get(_p25._1)
			};
		};
		return A2(_arturopala$elm_monocle$Monocle_Lens$Lens, get, set);
	});
var _arturopala$elm_monocle$Monocle_Lens$tuple = F2(
	function (left, right) {
		var set = F2(
			function (_p26, a) {
				var _p27 = _p26;
				return A2(
					right.set,
					_p27._1,
					A2(left.set, _p27._0, a));
			});
		var get = function (a) {
			return {
				ctor: '_Tuple2',
				_0: left.get(a),
				_1: right.get(a)
			};
		};
		return A2(_arturopala$elm_monocle$Monocle_Lens$Lens, get, set);
	});
var _arturopala$elm_monocle$Monocle_Lens$tuple3 = F3(
	function (first, second, third) {
		var set = F2(
			function (_p28, a) {
				var _p29 = _p28;
				return A2(
					third.set,
					_p29._2,
					A2(
						second.set,
						_p29._1,
						A2(first.set, _p29._0, a)));
			});
		var get = function (a) {
			return {
				ctor: '_Tuple3',
				_0: first.get(a),
				_1: second.get(a),
				_2: third.get(a)
			};
		};
		return A2(_arturopala$elm_monocle$Monocle_Lens$Lens, get, set);
	});


var _coreytrampe$elm_vendor$Native_Vendor = function(elm) {

    //  http://davidwalsh.name/vendor-prefix
    var styles = window.getComputedStyle(document.documentElement, '');
    var vendorPrefix = (Array.prototype.slice
        .call(styles)
        .join('')
        .match(/-(moz|webkit|ms)-/) || (styles.OLink === '' && ['', 'o'])
    )[1];

    return  { prefix: vendorPrefix };
}();

var _coreytrampe$elm_vendor$Vendor$Unknown = {ctor: 'Unknown'};
var _coreytrampe$elm_vendor$Vendor$O = {ctor: 'O'};
var _coreytrampe$elm_vendor$Vendor$MS = {ctor: 'MS'};
var _coreytrampe$elm_vendor$Vendor$Webkit = {ctor: 'Webkit'};
var _coreytrampe$elm_vendor$Vendor$Moz = {ctor: 'Moz'};
var _coreytrampe$elm_vendor$Vendor$prefix = _elm_lang$core$Native_Utils.eq(_coreytrampe$elm_vendor$Native_Vendor.prefix, 'webkit') ? _coreytrampe$elm_vendor$Vendor$Webkit : (_elm_lang$core$Native_Utils.eq(_coreytrampe$elm_vendor$Native_Vendor.prefix, 'moz') ? _coreytrampe$elm_vendor$Vendor$Moz : (_elm_lang$core$Native_Utils.eq(_coreytrampe$elm_vendor$Native_Vendor.prefix, 'ms') ? _coreytrampe$elm_vendor$Vendor$MS : (_elm_lang$core$Native_Utils.eq(_coreytrampe$elm_vendor$Native_Vendor.prefix, 'o') ? _coreytrampe$elm_vendor$Vendor$O : _coreytrampe$elm_vendor$Vendor$Unknown)));

var _elm_lang$core$Set$foldr = F3(
	function (f, b, _p0) {
		var _p1 = _p0;
		return A3(
			_elm_lang$core$Dict$foldr,
			F3(
				function (k, _p2, b) {
					return A2(f, k, b);
				}),
			b,
			_p1._0);
	});
var _elm_lang$core$Set$foldl = F3(
	function (f, b, _p3) {
		var _p4 = _p3;
		return A3(
			_elm_lang$core$Dict$foldl,
			F3(
				function (k, _p5, b) {
					return A2(f, k, b);
				}),
			b,
			_p4._0);
	});
var _elm_lang$core$Set$toList = function (_p6) {
	var _p7 = _p6;
	return _elm_lang$core$Dict$keys(_p7._0);
};
var _elm_lang$core$Set$size = function (_p8) {
	var _p9 = _p8;
	return _elm_lang$core$Dict$size(_p9._0);
};
var _elm_lang$core$Set$member = F2(
	function (k, _p10) {
		var _p11 = _p10;
		return A2(_elm_lang$core$Dict$member, k, _p11._0);
	});
var _elm_lang$core$Set$isEmpty = function (_p12) {
	var _p13 = _p12;
	return _elm_lang$core$Dict$isEmpty(_p13._0);
};
var _elm_lang$core$Set$Set_elm_builtin = function (a) {
	return {ctor: 'Set_elm_builtin', _0: a};
};
var _elm_lang$core$Set$empty = _elm_lang$core$Set$Set_elm_builtin(_elm_lang$core$Dict$empty);
var _elm_lang$core$Set$singleton = function (k) {
	return _elm_lang$core$Set$Set_elm_builtin(
		A2(
			_elm_lang$core$Dict$singleton,
			k,
			{ctor: '_Tuple0'}));
};
var _elm_lang$core$Set$insert = F2(
	function (k, _p14) {
		var _p15 = _p14;
		return _elm_lang$core$Set$Set_elm_builtin(
			A3(
				_elm_lang$core$Dict$insert,
				k,
				{ctor: '_Tuple0'},
				_p15._0));
	});
var _elm_lang$core$Set$fromList = function (xs) {
	return A3(_elm_lang$core$List$foldl, _elm_lang$core$Set$insert, _elm_lang$core$Set$empty, xs);
};
var _elm_lang$core$Set$map = F2(
	function (f, s) {
		return _elm_lang$core$Set$fromList(
			A2(
				_elm_lang$core$List$map,
				f,
				_elm_lang$core$Set$toList(s)));
	});
var _elm_lang$core$Set$remove = F2(
	function (k, _p16) {
		var _p17 = _p16;
		return _elm_lang$core$Set$Set_elm_builtin(
			A2(_elm_lang$core$Dict$remove, k, _p17._0));
	});
var _elm_lang$core$Set$union = F2(
	function (_p19, _p18) {
		var _p20 = _p19;
		var _p21 = _p18;
		return _elm_lang$core$Set$Set_elm_builtin(
			A2(_elm_lang$core$Dict$union, _p20._0, _p21._0));
	});
var _elm_lang$core$Set$intersect = F2(
	function (_p23, _p22) {
		var _p24 = _p23;
		var _p25 = _p22;
		return _elm_lang$core$Set$Set_elm_builtin(
			A2(_elm_lang$core$Dict$intersect, _p24._0, _p25._0));
	});
var _elm_lang$core$Set$diff = F2(
	function (_p27, _p26) {
		var _p28 = _p27;
		var _p29 = _p26;
		return _elm_lang$core$Set$Set_elm_builtin(
			A2(_elm_lang$core$Dict$diff, _p28._0, _p29._0));
	});
var _elm_lang$core$Set$filter = F2(
	function (p, _p30) {
		var _p31 = _p30;
		return _elm_lang$core$Set$Set_elm_builtin(
			A2(
				_elm_lang$core$Dict$filter,
				F2(
					function (k, _p32) {
						return p(k);
					}),
				_p31._0));
	});
var _elm_lang$core$Set$partition = F2(
	function (p, _p33) {
		var _p34 = _p33;
		var _p35 = A2(
			_elm_lang$core$Dict$partition,
			F2(
				function (k, _p36) {
					return p(k);
				}),
			_p34._0);
		var p1 = _p35._0;
		var p2 = _p35._1;
		return {
			ctor: '_Tuple2',
			_0: _elm_lang$core$Set$Set_elm_builtin(p1),
			_1: _elm_lang$core$Set$Set_elm_builtin(p2)
		};
	});

var _elm_community$list_extra$List_Extra$greedyGroupsOfWithStep = F3(
	function (size, step, xs) {
		var okayXs = _elm_lang$core$Native_Utils.cmp(
			_elm_lang$core$List$length(xs),
			0) > 0;
		var okayArgs = (_elm_lang$core$Native_Utils.cmp(size, 0) > 0) && (_elm_lang$core$Native_Utils.cmp(step, 0) > 0);
		var xs_ = A2(_elm_lang$core$List$drop, step, xs);
		var group = A2(_elm_lang$core$List$take, size, xs);
		return (okayArgs && okayXs) ? {
			ctor: '::',
			_0: group,
			_1: A3(_elm_community$list_extra$List_Extra$greedyGroupsOfWithStep, size, step, xs_)
		} : {ctor: '[]'};
	});
var _elm_community$list_extra$List_Extra$greedyGroupsOf = F2(
	function (size, xs) {
		return A3(_elm_community$list_extra$List_Extra$greedyGroupsOfWithStep, size, size, xs);
	});
var _elm_community$list_extra$List_Extra$groupsOfWithStep = F3(
	function (size, step, xs) {
		var okayArgs = (_elm_lang$core$Native_Utils.cmp(size, 0) > 0) && (_elm_lang$core$Native_Utils.cmp(step, 0) > 0);
		var xs_ = A2(_elm_lang$core$List$drop, step, xs);
		var group = A2(_elm_lang$core$List$take, size, xs);
		var okayLength = _elm_lang$core$Native_Utils.eq(
			size,
			_elm_lang$core$List$length(group));
		return (okayArgs && okayLength) ? {
			ctor: '::',
			_0: group,
			_1: A3(_elm_community$list_extra$List_Extra$groupsOfWithStep, size, step, xs_)
		} : {ctor: '[]'};
	});
var _elm_community$list_extra$List_Extra$groupsOf = F2(
	function (size, xs) {
		return A3(_elm_community$list_extra$List_Extra$groupsOfWithStep, size, size, xs);
	});
var _elm_community$list_extra$List_Extra$zip5 = _elm_lang$core$List$map5(
	F5(
		function (v0, v1, v2, v3, v4) {
			return {ctor: '_Tuple5', _0: v0, _1: v1, _2: v2, _3: v3, _4: v4};
		}));
var _elm_community$list_extra$List_Extra$zip4 = _elm_lang$core$List$map4(
	F4(
		function (v0, v1, v2, v3) {
			return {ctor: '_Tuple4', _0: v0, _1: v1, _2: v2, _3: v3};
		}));
var _elm_community$list_extra$List_Extra$zip3 = _elm_lang$core$List$map3(
	F3(
		function (v0, v1, v2) {
			return {ctor: '_Tuple3', _0: v0, _1: v1, _2: v2};
		}));
var _elm_community$list_extra$List_Extra$zip = _elm_lang$core$List$map2(
	F2(
		function (v0, v1) {
			return {ctor: '_Tuple2', _0: v0, _1: v1};
		}));
var _elm_community$list_extra$List_Extra$isPrefixOf = function (prefix) {
	return function (_p0) {
		return A2(
			_elm_lang$core$List$all,
			_elm_lang$core$Basics$identity,
			A3(
				_elm_lang$core$List$map2,
				F2(
					function (x, y) {
						return _elm_lang$core$Native_Utils.eq(x, y);
					}),
				prefix,
				_p0));
	};
};
var _elm_community$list_extra$List_Extra$isSuffixOf = F2(
	function (suffix, xs) {
		return A2(
			_elm_community$list_extra$List_Extra$isPrefixOf,
			_elm_lang$core$List$reverse(suffix),
			_elm_lang$core$List$reverse(xs));
	});
var _elm_community$list_extra$List_Extra$selectSplit = function (xs) {
	var _p1 = xs;
	if (_p1.ctor === '[]') {
		return {ctor: '[]'};
	} else {
		var _p5 = _p1._1;
		var _p4 = _p1._0;
		return {
			ctor: '::',
			_0: {
				ctor: '_Tuple3',
				_0: {ctor: '[]'},
				_1: _p4,
				_2: _p5
			},
			_1: A2(
				_elm_lang$core$List$map,
				function (_p2) {
					var _p3 = _p2;
					return {
						ctor: '_Tuple3',
						_0: {ctor: '::', _0: _p4, _1: _p3._0},
						_1: _p3._1,
						_2: _p3._2
					};
				},
				_elm_community$list_extra$List_Extra$selectSplit(_p5))
		};
	}
};
var _elm_community$list_extra$List_Extra$select = function (xs) {
	var _p6 = xs;
	if (_p6.ctor === '[]') {
		return {ctor: '[]'};
	} else {
		var _p10 = _p6._1;
		var _p9 = _p6._0;
		return {
			ctor: '::',
			_0: {ctor: '_Tuple2', _0: _p9, _1: _p10},
			_1: A2(
				_elm_lang$core$List$map,
				function (_p7) {
					var _p8 = _p7;
					return {
						ctor: '_Tuple2',
						_0: _p8._0,
						_1: {ctor: '::', _0: _p9, _1: _p8._1}
					};
				},
				_elm_community$list_extra$List_Extra$select(_p10))
		};
	}
};
var _elm_community$list_extra$List_Extra$tailsHelp = F2(
	function (e, list) {
		var _p11 = list;
		if (_p11.ctor === '::') {
			var _p12 = _p11._0;
			return {
				ctor: '::',
				_0: {ctor: '::', _0: e, _1: _p12},
				_1: {ctor: '::', _0: _p12, _1: _p11._1}
			};
		} else {
			return {ctor: '[]'};
		}
	});
var _elm_community$list_extra$List_Extra$tails = A2(
	_elm_lang$core$List$foldr,
	_elm_community$list_extra$List_Extra$tailsHelp,
	{
		ctor: '::',
		_0: {ctor: '[]'},
		_1: {ctor: '[]'}
	});
var _elm_community$list_extra$List_Extra$isInfixOf = F2(
	function (infix, xs) {
		return A2(
			_elm_lang$core$List$any,
			_elm_community$list_extra$List_Extra$isPrefixOf(infix),
			_elm_community$list_extra$List_Extra$tails(xs));
	});
var _elm_community$list_extra$List_Extra$inits = A2(
	_elm_lang$core$List$foldr,
	F2(
		function (e, acc) {
			return {
				ctor: '::',
				_0: {ctor: '[]'},
				_1: A2(
					_elm_lang$core$List$map,
					F2(
						function (x, y) {
							return {ctor: '::', _0: x, _1: y};
						})(e),
					acc)
			};
		}),
	{
		ctor: '::',
		_0: {ctor: '[]'},
		_1: {ctor: '[]'}
	});
var _elm_community$list_extra$List_Extra$groupWhileTransitively = F2(
	function (cmp, xs_) {
		var _p13 = xs_;
		if (_p13.ctor === '[]') {
			return {ctor: '[]'};
		} else {
			if (_p13._1.ctor === '[]') {
				return {
					ctor: '::',
					_0: {
						ctor: '::',
						_0: _p13._0,
						_1: {ctor: '[]'}
					},
					_1: {ctor: '[]'}
				};
			} else {
				var _p15 = _p13._0;
				var _p14 = A2(_elm_community$list_extra$List_Extra$groupWhileTransitively, cmp, _p13._1);
				if (_p14.ctor === '::') {
					return A2(cmp, _p15, _p13._1._0) ? {
						ctor: '::',
						_0: {ctor: '::', _0: _p15, _1: _p14._0},
						_1: _p14._1
					} : {
						ctor: '::',
						_0: {
							ctor: '::',
							_0: _p15,
							_1: {ctor: '[]'}
						},
						_1: _p14
					};
				} else {
					return {ctor: '[]'};
				}
			}
		}
	});
var _elm_community$list_extra$List_Extra$stripPrefix = F2(
	function (prefix, xs) {
		var step = F2(
			function (e, m) {
				var _p16 = m;
				if (_p16.ctor === 'Nothing') {
					return _elm_lang$core$Maybe$Nothing;
				} else {
					if (_p16._0.ctor === '[]') {
						return _elm_lang$core$Maybe$Nothing;
					} else {
						return _elm_lang$core$Native_Utils.eq(e, _p16._0._0) ? _elm_lang$core$Maybe$Just(_p16._0._1) : _elm_lang$core$Maybe$Nothing;
					}
				}
			});
		return A3(
			_elm_lang$core$List$foldl,
			step,
			_elm_lang$core$Maybe$Just(xs),
			prefix);
	});
var _elm_community$list_extra$List_Extra$dropWhileRight = function (p) {
	return A2(
		_elm_lang$core$List$foldr,
		F2(
			function (x, xs) {
				return (p(x) && _elm_lang$core$List$isEmpty(xs)) ? {ctor: '[]'} : {ctor: '::', _0: x, _1: xs};
			}),
		{ctor: '[]'});
};
var _elm_community$list_extra$List_Extra$takeWhileRight = function (p) {
	var step = F2(
		function (x, _p17) {
			var _p18 = _p17;
			var _p19 = _p18._0;
			return (p(x) && _p18._1) ? {
				ctor: '_Tuple2',
				_0: {ctor: '::', _0: x, _1: _p19},
				_1: true
			} : {ctor: '_Tuple2', _0: _p19, _1: false};
		});
	return function (_p20) {
		return _elm_lang$core$Tuple$first(
			A3(
				_elm_lang$core$List$foldr,
				step,
				{
					ctor: '_Tuple2',
					_0: {ctor: '[]'},
					_1: true
				},
				_p20));
	};
};
var _elm_community$list_extra$List_Extra$splitAt = F2(
	function (n, xs) {
		return {
			ctor: '_Tuple2',
			_0: A2(_elm_lang$core$List$take, n, xs),
			_1: A2(_elm_lang$core$List$drop, n, xs)
		};
	});
var _elm_community$list_extra$List_Extra$groupsOfVarying_ = F3(
	function (listOflengths, list, accu) {
		groupsOfVarying_:
		while (true) {
			var _p21 = {ctor: '_Tuple2', _0: listOflengths, _1: list};
			if (((_p21.ctor === '_Tuple2') && (_p21._0.ctor === '::')) && (_p21._1.ctor === '::')) {
				var _p22 = A2(_elm_community$list_extra$List_Extra$splitAt, _p21._0._0, list);
				var head = _p22._0;
				var tail = _p22._1;
				var _v10 = _p21._0._1,
					_v11 = tail,
					_v12 = {ctor: '::', _0: head, _1: accu};
				listOflengths = _v10;
				list = _v11;
				accu = _v12;
				continue groupsOfVarying_;
			} else {
				return _elm_lang$core$List$reverse(accu);
			}
		}
	});
var _elm_community$list_extra$List_Extra$groupsOfVarying = F2(
	function (listOflengths, list) {
		return A3(
			_elm_community$list_extra$List_Extra$groupsOfVarying_,
			listOflengths,
			list,
			{ctor: '[]'});
	});
var _elm_community$list_extra$List_Extra$unfoldr = F2(
	function (f, seed) {
		var _p23 = f(seed);
		if (_p23.ctor === 'Nothing') {
			return {ctor: '[]'};
		} else {
			return {
				ctor: '::',
				_0: _p23._0._0,
				_1: A2(_elm_community$list_extra$List_Extra$unfoldr, f, _p23._0._1)
			};
		}
	});
var _elm_community$list_extra$List_Extra$scanr1 = F2(
	function (f, xs_) {
		var _p24 = xs_;
		if (_p24.ctor === '[]') {
			return {ctor: '[]'};
		} else {
			if (_p24._1.ctor === '[]') {
				return {
					ctor: '::',
					_0: _p24._0,
					_1: {ctor: '[]'}
				};
			} else {
				var _p25 = A2(_elm_community$list_extra$List_Extra$scanr1, f, _p24._1);
				if (_p25.ctor === '::') {
					return {
						ctor: '::',
						_0: A2(f, _p24._0, _p25._0),
						_1: _p25
					};
				} else {
					return {ctor: '[]'};
				}
			}
		}
	});
var _elm_community$list_extra$List_Extra$scanr = F3(
	function (f, acc, xs_) {
		var _p26 = xs_;
		if (_p26.ctor === '[]') {
			return {
				ctor: '::',
				_0: acc,
				_1: {ctor: '[]'}
			};
		} else {
			var _p27 = A3(_elm_community$list_extra$List_Extra$scanr, f, acc, _p26._1);
			if (_p27.ctor === '::') {
				return {
					ctor: '::',
					_0: A2(f, _p26._0, _p27._0),
					_1: _p27
				};
			} else {
				return {ctor: '[]'};
			}
		}
	});
var _elm_community$list_extra$List_Extra$scanl1 = F2(
	function (f, xs_) {
		var _p28 = xs_;
		if (_p28.ctor === '[]') {
			return {ctor: '[]'};
		} else {
			return A3(_elm_lang$core$List$scanl, f, _p28._0, _p28._1);
		}
	});
var _elm_community$list_extra$List_Extra$indexedFoldr = F3(
	function (func, acc, list) {
		var step = F2(
			function (x, _p29) {
				var _p30 = _p29;
				var _p31 = _p30._0;
				return {
					ctor: '_Tuple2',
					_0: _p31 - 1,
					_1: A3(func, _p31, x, _p30._1)
				};
			});
		return _elm_lang$core$Tuple$second(
			A3(
				_elm_lang$core$List$foldr,
				step,
				{
					ctor: '_Tuple2',
					_0: _elm_lang$core$List$length(list) - 1,
					_1: acc
				},
				list));
	});
var _elm_community$list_extra$List_Extra$indexedFoldl = F3(
	function (func, acc, list) {
		var step = F2(
			function (x, _p32) {
				var _p33 = _p32;
				var _p34 = _p33._0;
				return {
					ctor: '_Tuple2',
					_0: _p34 + 1,
					_1: A3(func, _p34, x, _p33._1)
				};
			});
		return _elm_lang$core$Tuple$second(
			A3(
				_elm_lang$core$List$foldl,
				step,
				{ctor: '_Tuple2', _0: 0, _1: acc},
				list));
	});
var _elm_community$list_extra$List_Extra$foldr1 = F2(
	function (f, xs) {
		var mf = F2(
			function (x, m) {
				return _elm_lang$core$Maybe$Just(
					function () {
						var _p35 = m;
						if (_p35.ctor === 'Nothing') {
							return x;
						} else {
							return A2(f, x, _p35._0);
						}
					}());
			});
		return A3(_elm_lang$core$List$foldr, mf, _elm_lang$core$Maybe$Nothing, xs);
	});
var _elm_community$list_extra$List_Extra$foldl1 = F2(
	function (f, xs) {
		var mf = F2(
			function (x, m) {
				return _elm_lang$core$Maybe$Just(
					function () {
						var _p36 = m;
						if (_p36.ctor === 'Nothing') {
							return x;
						} else {
							return A2(f, _p36._0, x);
						}
					}());
			});
		return A3(_elm_lang$core$List$foldl, mf, _elm_lang$core$Maybe$Nothing, xs);
	});
var _elm_community$list_extra$List_Extra$interweaveHelp = F3(
	function (l1, l2, acc) {
		interweaveHelp:
		while (true) {
			var _p37 = {ctor: '_Tuple2', _0: l1, _1: l2};
			_v23_1:
			do {
				if (_p37._0.ctor === '::') {
					if (_p37._1.ctor === '::') {
						var _v24 = _p37._0._1,
							_v25 = _p37._1._1,
							_v26 = A2(
							_elm_lang$core$Basics_ops['++'],
							acc,
							{
								ctor: '::',
								_0: _p37._0._0,
								_1: {
									ctor: '::',
									_0: _p37._1._0,
									_1: {ctor: '[]'}
								}
							});
						l1 = _v24;
						l2 = _v25;
						acc = _v26;
						continue interweaveHelp;
					} else {
						break _v23_1;
					}
				} else {
					if (_p37._1.ctor === '[]') {
						break _v23_1;
					} else {
						return A2(_elm_lang$core$Basics_ops['++'], acc, _p37._1);
					}
				}
			} while(false);
			return A2(_elm_lang$core$Basics_ops['++'], acc, _p37._0);
		}
	});
var _elm_community$list_extra$List_Extra$interweave = F2(
	function (l1, l2) {
		return A3(
			_elm_community$list_extra$List_Extra$interweaveHelp,
			l1,
			l2,
			{ctor: '[]'});
	});
var _elm_community$list_extra$List_Extra$permutations = function (xs_) {
	var _p38 = xs_;
	if (_p38.ctor === '[]') {
		return {
			ctor: '::',
			_0: {ctor: '[]'},
			_1: {ctor: '[]'}
		};
	} else {
		var f = function (_p39) {
			var _p40 = _p39;
			return A2(
				_elm_lang$core$List$map,
				F2(
					function (x, y) {
						return {ctor: '::', _0: x, _1: y};
					})(_p40._0),
				_elm_community$list_extra$List_Extra$permutations(_p40._1));
		};
		return A2(
			_elm_lang$core$List$concatMap,
			f,
			_elm_community$list_extra$List_Extra$select(_p38));
	}
};
var _elm_community$list_extra$List_Extra$isPermutationOf = F2(
	function (permut, xs) {
		return A2(
			_elm_lang$core$List$member,
			permut,
			_elm_community$list_extra$List_Extra$permutations(xs));
	});
var _elm_community$list_extra$List_Extra$subsequencesNonEmpty = function (xs) {
	var _p41 = xs;
	if (_p41.ctor === '[]') {
		return {ctor: '[]'};
	} else {
		var _p42 = _p41._0;
		var f = F2(
			function (ys, r) {
				return {
					ctor: '::',
					_0: ys,
					_1: {
						ctor: '::',
						_0: {ctor: '::', _0: _p42, _1: ys},
						_1: r
					}
				};
			});
		return {
			ctor: '::',
			_0: {
				ctor: '::',
				_0: _p42,
				_1: {ctor: '[]'}
			},
			_1: A3(
				_elm_lang$core$List$foldr,
				f,
				{ctor: '[]'},
				_elm_community$list_extra$List_Extra$subsequencesNonEmpty(_p41._1))
		};
	}
};
var _elm_community$list_extra$List_Extra$subsequences = function (xs) {
	return {
		ctor: '::',
		_0: {ctor: '[]'},
		_1: _elm_community$list_extra$List_Extra$subsequencesNonEmpty(xs)
	};
};
var _elm_community$list_extra$List_Extra$isSubsequenceOf = F2(
	function (subseq, xs) {
		return A2(
			_elm_lang$core$List$member,
			subseq,
			_elm_community$list_extra$List_Extra$subsequences(xs));
	});
var _elm_community$list_extra$List_Extra$transpose = function (ll) {
	transpose:
	while (true) {
		var _p43 = ll;
		if (_p43.ctor === '[]') {
			return {ctor: '[]'};
		} else {
			if (_p43._0.ctor === '[]') {
				var _v31 = _p43._1;
				ll = _v31;
				continue transpose;
			} else {
				var _p44 = _p43._1;
				var tails = A2(_elm_lang$core$List$filterMap, _elm_lang$core$List$tail, _p44);
				var heads = A2(_elm_lang$core$List$filterMap, _elm_lang$core$List$head, _p44);
				return {
					ctor: '::',
					_0: {ctor: '::', _0: _p43._0._0, _1: heads},
					_1: _elm_community$list_extra$List_Extra$transpose(
						{ctor: '::', _0: _p43._0._1, _1: tails})
				};
			}
		}
	}
};
var _elm_community$list_extra$List_Extra$intercalate = function (xs) {
	return function (_p45) {
		return _elm_lang$core$List$concat(
			A2(_elm_lang$core$List$intersperse, xs, _p45));
	};
};
var _elm_community$list_extra$List_Extra$filterNot = F2(
	function (pred, list) {
		return A2(
			_elm_lang$core$List$filter,
			function (_p46) {
				return !pred(_p46);
			},
			list);
	});
var _elm_community$list_extra$List_Extra$removeAt = F2(
	function (index, l) {
		if (_elm_lang$core$Native_Utils.cmp(index, 0) < 0) {
			return l;
		} else {
			var tail = _elm_lang$core$List$tail(
				A2(_elm_lang$core$List$drop, index, l));
			var head = A2(_elm_lang$core$List$take, index, l);
			var _p47 = tail;
			if (_p47.ctor === 'Nothing') {
				return l;
			} else {
				return A2(_elm_lang$core$List$append, head, _p47._0);
			}
		}
	});
var _elm_community$list_extra$List_Extra$singleton = function (x) {
	return {
		ctor: '::',
		_0: x,
		_1: {ctor: '[]'}
	};
};
var _elm_community$list_extra$List_Extra$stableSortWith = F2(
	function (pred, list) {
		var predWithIndex = F2(
			function (_p49, _p48) {
				var _p50 = _p49;
				var _p51 = _p48;
				var result = A2(pred, _p50._0, _p51._0);
				var _p52 = result;
				if (_p52.ctor === 'EQ') {
					return A2(_elm_lang$core$Basics$compare, _p50._1, _p51._1);
				} else {
					return result;
				}
			});
		var listWithIndex = A2(
			_elm_lang$core$List$indexedMap,
			F2(
				function (i, a) {
					return {ctor: '_Tuple2', _0: a, _1: i};
				}),
			list);
		return A2(
			_elm_lang$core$List$map,
			_elm_lang$core$Tuple$first,
			A2(_elm_lang$core$List$sortWith, predWithIndex, listWithIndex));
	});
var _elm_community$list_extra$List_Extra$setAt = F3(
	function (index, value, l) {
		if (_elm_lang$core$Native_Utils.cmp(index, 0) < 0) {
			return _elm_lang$core$Maybe$Nothing;
		} else {
			var tail = _elm_lang$core$List$tail(
				A2(_elm_lang$core$List$drop, index, l));
			var head = A2(_elm_lang$core$List$take, index, l);
			var _p53 = tail;
			if (_p53.ctor === 'Nothing') {
				return _elm_lang$core$Maybe$Nothing;
			} else {
				return _elm_lang$core$Maybe$Just(
					A2(
						_elm_lang$core$List$append,
						head,
						{ctor: '::', _0: value, _1: _p53._0}));
			}
		}
	});
var _elm_community$list_extra$List_Extra$remove = F2(
	function (x, xs) {
		var _p54 = xs;
		if (_p54.ctor === '[]') {
			return {ctor: '[]'};
		} else {
			var _p56 = _p54._1;
			var _p55 = _p54._0;
			return _elm_lang$core$Native_Utils.eq(x, _p55) ? _p56 : {
				ctor: '::',
				_0: _p55,
				_1: A2(_elm_community$list_extra$List_Extra$remove, x, _p56)
			};
		}
	});
var _elm_community$list_extra$List_Extra$updateIfIndex = F3(
	function (predicate, update, list) {
		return A2(
			_elm_lang$core$List$indexedMap,
			F2(
				function (i, x) {
					return predicate(i) ? update(x) : x;
				}),
			list);
	});
var _elm_community$list_extra$List_Extra$updateAt = F3(
	function (index, update, list) {
		return ((_elm_lang$core$Native_Utils.cmp(index, 0) < 0) || (_elm_lang$core$Native_Utils.cmp(
			index,
			_elm_lang$core$List$length(list)) > -1)) ? _elm_lang$core$Maybe$Nothing : _elm_lang$core$Maybe$Just(
			A3(
				_elm_community$list_extra$List_Extra$updateIfIndex,
				F2(
					function (x, y) {
						return _elm_lang$core$Native_Utils.eq(x, y);
					})(index),
				update,
				list));
	});
var _elm_community$list_extra$List_Extra$updateIf = F3(
	function (predicate, update, list) {
		return A2(
			_elm_lang$core$List$map,
			function (item) {
				return predicate(item) ? update(item) : item;
			},
			list);
	});
var _elm_community$list_extra$List_Extra$replaceIf = F3(
	function (predicate, replacement, list) {
		return A3(
			_elm_community$list_extra$List_Extra$updateIf,
			predicate,
			_elm_lang$core$Basics$always(replacement),
			list);
	});
var _elm_community$list_extra$List_Extra$findIndices = function (p) {
	return function (_p57) {
		return A2(
			_elm_lang$core$List$map,
			_elm_lang$core$Tuple$first,
			A2(
				_elm_lang$core$List$filter,
				function (_p58) {
					var _p59 = _p58;
					return p(_p59._1);
				},
				A2(
					_elm_lang$core$List$indexedMap,
					F2(
						function (v0, v1) {
							return {ctor: '_Tuple2', _0: v0, _1: v1};
						}),
					_p57)));
	};
};
var _elm_community$list_extra$List_Extra$findIndex = function (p) {
	return function (_p60) {
		return _elm_lang$core$List$head(
			A2(_elm_community$list_extra$List_Extra$findIndices, p, _p60));
	};
};
var _elm_community$list_extra$List_Extra$elemIndices = function (x) {
	return _elm_community$list_extra$List_Extra$findIndices(
		F2(
			function (x, y) {
				return _elm_lang$core$Native_Utils.eq(x, y);
			})(x));
};
var _elm_community$list_extra$List_Extra$elemIndex = function (x) {
	return _elm_community$list_extra$List_Extra$findIndex(
		F2(
			function (x, y) {
				return _elm_lang$core$Native_Utils.eq(x, y);
			})(x));
};
var _elm_community$list_extra$List_Extra$find = F2(
	function (predicate, list) {
		find:
		while (true) {
			var _p61 = list;
			if (_p61.ctor === '[]') {
				return _elm_lang$core$Maybe$Nothing;
			} else {
				var _p62 = _p61._0;
				if (predicate(_p62)) {
					return _elm_lang$core$Maybe$Just(_p62);
				} else {
					var _v40 = predicate,
						_v41 = _p61._1;
					predicate = _v40;
					list = _v41;
					continue find;
				}
			}
		}
	});
var _elm_community$list_extra$List_Extra$notMember = function (x) {
	return function (_p63) {
		return !A2(_elm_lang$core$List$member, x, _p63);
	};
};
var _elm_community$list_extra$List_Extra$andThen = _elm_lang$core$List$concatMap;
var _elm_community$list_extra$List_Extra$lift2 = F3(
	function (f, la, lb) {
		return A2(
			_elm_community$list_extra$List_Extra$andThen,
			function (a) {
				return A2(
					_elm_community$list_extra$List_Extra$andThen,
					function (b) {
						return {
							ctor: '::',
							_0: A2(f, a, b),
							_1: {ctor: '[]'}
						};
					},
					lb);
			},
			la);
	});
var _elm_community$list_extra$List_Extra$lift3 = F4(
	function (f, la, lb, lc) {
		return A2(
			_elm_community$list_extra$List_Extra$andThen,
			function (a) {
				return A2(
					_elm_community$list_extra$List_Extra$andThen,
					function (b) {
						return A2(
							_elm_community$list_extra$List_Extra$andThen,
							function (c) {
								return {
									ctor: '::',
									_0: A3(f, a, b, c),
									_1: {ctor: '[]'}
								};
							},
							lc);
					},
					lb);
			},
			la);
	});
var _elm_community$list_extra$List_Extra$lift4 = F5(
	function (f, la, lb, lc, ld) {
		return A2(
			_elm_community$list_extra$List_Extra$andThen,
			function (a) {
				return A2(
					_elm_community$list_extra$List_Extra$andThen,
					function (b) {
						return A2(
							_elm_community$list_extra$List_Extra$andThen,
							function (c) {
								return A2(
									_elm_community$list_extra$List_Extra$andThen,
									function (d) {
										return {
											ctor: '::',
											_0: A4(f, a, b, c, d),
											_1: {ctor: '[]'}
										};
									},
									ld);
							},
							lc);
					},
					lb);
			},
			la);
	});
var _elm_community$list_extra$List_Extra$andMap = F2(
	function (fl, l) {
		return A3(
			_elm_lang$core$List$map2,
			F2(
				function (x, y) {
					return x(y);
				}),
			fl,
			l);
	});
var _elm_community$list_extra$List_Extra$uniqueHelp = F3(
	function (f, existing, remaining) {
		uniqueHelp:
		while (true) {
			var _p64 = remaining;
			if (_p64.ctor === '[]') {
				return {ctor: '[]'};
			} else {
				var _p66 = _p64._1;
				var _p65 = _p64._0;
				var computedFirst = f(_p65);
				if (A2(_elm_lang$core$Set$member, computedFirst, existing)) {
					var _v43 = f,
						_v44 = existing,
						_v45 = _p66;
					f = _v43;
					existing = _v44;
					remaining = _v45;
					continue uniqueHelp;
				} else {
					return {
						ctor: '::',
						_0: _p65,
						_1: A3(
							_elm_community$list_extra$List_Extra$uniqueHelp,
							f,
							A2(_elm_lang$core$Set$insert, computedFirst, existing),
							_p66)
					};
				}
			}
		}
	});
var _elm_community$list_extra$List_Extra$uniqueBy = F2(
	function (f, list) {
		return A3(_elm_community$list_extra$List_Extra$uniqueHelp, f, _elm_lang$core$Set$empty, list);
	});
var _elm_community$list_extra$List_Extra$allDifferentBy = F2(
	function (f, list) {
		return _elm_lang$core$Native_Utils.eq(
			_elm_lang$core$List$length(list),
			_elm_lang$core$List$length(
				A2(_elm_community$list_extra$List_Extra$uniqueBy, f, list)));
	});
var _elm_community$list_extra$List_Extra$unique = function (list) {
	return A3(_elm_community$list_extra$List_Extra$uniqueHelp, _elm_lang$core$Basics$identity, _elm_lang$core$Set$empty, list);
};
var _elm_community$list_extra$List_Extra$allDifferent = function (list) {
	return _elm_lang$core$Native_Utils.eq(
		_elm_lang$core$List$length(list),
		_elm_lang$core$List$length(
			_elm_community$list_extra$List_Extra$unique(list)));
};
var _elm_community$list_extra$List_Extra$dropWhile = F2(
	function (predicate, list) {
		dropWhile:
		while (true) {
			var _p67 = list;
			if (_p67.ctor === '[]') {
				return {ctor: '[]'};
			} else {
				if (predicate(_p67._0)) {
					var _v47 = predicate,
						_v48 = _p67._1;
					predicate = _v47;
					list = _v48;
					continue dropWhile;
				} else {
					return list;
				}
			}
		}
	});
var _elm_community$list_extra$List_Extra$takeWhile = F2(
	function (predicate, list) {
		var _p68 = list;
		if (_p68.ctor === '[]') {
			return {ctor: '[]'};
		} else {
			var _p69 = _p68._0;
			return predicate(_p69) ? {
				ctor: '::',
				_0: _p69,
				_1: A2(_elm_community$list_extra$List_Extra$takeWhile, predicate, _p68._1)
			} : {ctor: '[]'};
		}
	});
var _elm_community$list_extra$List_Extra$span = F2(
	function (p, xs) {
		return {
			ctor: '_Tuple2',
			_0: A2(_elm_community$list_extra$List_Extra$takeWhile, p, xs),
			_1: A2(_elm_community$list_extra$List_Extra$dropWhile, p, xs)
		};
	});
var _elm_community$list_extra$List_Extra$break = function (p) {
	return _elm_community$list_extra$List_Extra$span(
		function (_p70) {
			return !p(_p70);
		});
};
var _elm_community$list_extra$List_Extra$groupWhile = F2(
	function (eq, xs_) {
		var _p71 = xs_;
		if (_p71.ctor === '[]') {
			return {ctor: '[]'};
		} else {
			var _p73 = _p71._0;
			var _p72 = A2(
				_elm_community$list_extra$List_Extra$span,
				eq(_p73),
				_p71._1);
			var ys = _p72._0;
			var zs = _p72._1;
			return {
				ctor: '::',
				_0: {ctor: '::', _0: _p73, _1: ys},
				_1: A2(_elm_community$list_extra$List_Extra$groupWhile, eq, zs)
			};
		}
	});
var _elm_community$list_extra$List_Extra$group = _elm_community$list_extra$List_Extra$groupWhile(
	F2(
		function (x, y) {
			return _elm_lang$core$Native_Utils.eq(x, y);
		}));
var _elm_community$list_extra$List_Extra$minimumBy = F2(
	function (f, ls) {
		var minBy = F2(
			function (x, _p74) {
				var _p75 = _p74;
				var _p76 = _p75._1;
				var fx = f(x);
				return (_elm_lang$core$Native_Utils.cmp(fx, _p76) < 0) ? {ctor: '_Tuple2', _0: x, _1: fx} : {ctor: '_Tuple2', _0: _p75._0, _1: _p76};
			});
		var _p77 = ls;
		if (_p77.ctor === '::') {
			if (_p77._1.ctor === '[]') {
				return _elm_lang$core$Maybe$Just(_p77._0);
			} else {
				var _p78 = _p77._0;
				return _elm_lang$core$Maybe$Just(
					_elm_lang$core$Tuple$first(
						A3(
							_elm_lang$core$List$foldl,
							minBy,
							{
								ctor: '_Tuple2',
								_0: _p78,
								_1: f(_p78)
							},
							_p77._1)));
			}
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_community$list_extra$List_Extra$maximumBy = F2(
	function (f, ls) {
		var maxBy = F2(
			function (x, _p79) {
				var _p80 = _p79;
				var _p81 = _p80._1;
				var fx = f(x);
				return (_elm_lang$core$Native_Utils.cmp(fx, _p81) > 0) ? {ctor: '_Tuple2', _0: x, _1: fx} : {ctor: '_Tuple2', _0: _p80._0, _1: _p81};
			});
		var _p82 = ls;
		if (_p82.ctor === '::') {
			if (_p82._1.ctor === '[]') {
				return _elm_lang$core$Maybe$Just(_p82._0);
			} else {
				var _p83 = _p82._0;
				return _elm_lang$core$Maybe$Just(
					_elm_lang$core$Tuple$first(
						A3(
							_elm_lang$core$List$foldl,
							maxBy,
							{
								ctor: '_Tuple2',
								_0: _p83,
								_1: f(_p83)
							},
							_p82._1)));
			}
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_community$list_extra$List_Extra$uncons = function (xs) {
	var _p84 = xs;
	if (_p84.ctor === '[]') {
		return _elm_lang$core$Maybe$Nothing;
	} else {
		return _elm_lang$core$Maybe$Just(
			{ctor: '_Tuple2', _0: _p84._0, _1: _p84._1});
	}
};
var _elm_community$list_extra$List_Extra$swapAt = F3(
	function (index1, index2, l) {
		swapAt:
		while (true) {
			if (_elm_lang$core$Native_Utils.eq(index1, index2)) {
				return _elm_lang$core$Maybe$Just(l);
			} else {
				if (_elm_lang$core$Native_Utils.cmp(index1, index2) > 0) {
					var _v56 = index2,
						_v57 = index1,
						_v58 = l;
					index1 = _v56;
					index2 = _v57;
					l = _v58;
					continue swapAt;
				} else {
					if (_elm_lang$core$Native_Utils.cmp(index1, 0) < 0) {
						return _elm_lang$core$Maybe$Nothing;
					} else {
						var _p85 = A2(_elm_community$list_extra$List_Extra$splitAt, index1, l);
						var part1 = _p85._0;
						var tail1 = _p85._1;
						var _p86 = A2(_elm_community$list_extra$List_Extra$splitAt, index2 - index1, tail1);
						var head2 = _p86._0;
						var tail2 = _p86._1;
						return A3(
							_elm_lang$core$Maybe$map2,
							F2(
								function (_p88, _p87) {
									var _p89 = _p88;
									var _p90 = _p87;
									return _elm_lang$core$List$concat(
										{
											ctor: '::',
											_0: part1,
											_1: {
												ctor: '::',
												_0: {ctor: '::', _0: _p90._0, _1: _p89._1},
												_1: {
													ctor: '::',
													_0: {ctor: '::', _0: _p89._0, _1: _p90._1},
													_1: {ctor: '[]'}
												}
											}
										});
								}),
							_elm_community$list_extra$List_Extra$uncons(head2),
							_elm_community$list_extra$List_Extra$uncons(tail2));
					}
				}
			}
		}
	});
var _elm_community$list_extra$List_Extra$iterate = F2(
	function (f, x) {
		var _p91 = f(x);
		if (_p91.ctor === 'Just') {
			return {
				ctor: '::',
				_0: x,
				_1: A2(_elm_community$list_extra$List_Extra$iterate, f, _p91._0)
			};
		} else {
			return {
				ctor: '::',
				_0: x,
				_1: {ctor: '[]'}
			};
		}
	});
var _elm_community$list_extra$List_Extra$getAt = F2(
	function (idx, xs) {
		return (_elm_lang$core$Native_Utils.cmp(idx, 0) < 0) ? _elm_lang$core$Maybe$Nothing : _elm_lang$core$List$head(
			A2(_elm_lang$core$List$drop, idx, xs));
	});
var _elm_community$list_extra$List_Extra_ops = _elm_community$list_extra$List_Extra_ops || {};
_elm_community$list_extra$List_Extra_ops['!!'] = _elm_lang$core$Basics$flip(_elm_community$list_extra$List_Extra$getAt);
var _elm_community$list_extra$List_Extra$init = function () {
	var maybe = F2(
		function (d, f) {
			return function (_p92) {
				return A2(
					_elm_lang$core$Maybe$withDefault,
					d,
					A2(_elm_lang$core$Maybe$map, f, _p92));
			};
		});
	return A2(
		_elm_lang$core$List$foldr,
		function (x) {
			return function (_p93) {
				return _elm_lang$core$Maybe$Just(
					A3(
						maybe,
						{ctor: '[]'},
						F2(
							function (x, y) {
								return {ctor: '::', _0: x, _1: y};
							})(x),
						_p93));
			};
		},
		_elm_lang$core$Maybe$Nothing);
}();
var _elm_community$list_extra$List_Extra$last = _elm_community$list_extra$List_Extra$foldl1(
	_elm_lang$core$Basics$flip(_elm_lang$core$Basics$always));

//import Maybe, Native.List //

var _elm_lang$core$Native_Regex = function() {

function escape(str)
{
	return str.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&');
}
function caseInsensitive(re)
{
	return new RegExp(re.source, 'gi');
}
function regex(raw)
{
	return new RegExp(raw, 'g');
}

function contains(re, string)
{
	return string.match(re) !== null;
}

function find(n, re, str)
{
	n = n.ctor === 'All' ? Infinity : n._0;
	var out = [];
	var number = 0;
	var string = str;
	var lastIndex = re.lastIndex;
	var prevLastIndex = -1;
	var result;
	while (number++ < n && (result = re.exec(string)))
	{
		if (prevLastIndex === re.lastIndex) break;
		var i = result.length - 1;
		var subs = new Array(i);
		while (i > 0)
		{
			var submatch = result[i];
			subs[--i] = submatch === undefined
				? _elm_lang$core$Maybe$Nothing
				: _elm_lang$core$Maybe$Just(submatch);
		}
		out.push({
			match: result[0],
			submatches: _elm_lang$core$Native_List.fromArray(subs),
			index: result.index,
			number: number
		});
		prevLastIndex = re.lastIndex;
	}
	re.lastIndex = lastIndex;
	return _elm_lang$core$Native_List.fromArray(out);
}

function replace(n, re, replacer, string)
{
	n = n.ctor === 'All' ? Infinity : n._0;
	var count = 0;
	function jsReplacer(match)
	{
		if (count++ >= n)
		{
			return match;
		}
		var i = arguments.length - 3;
		var submatches = new Array(i);
		while (i > 0)
		{
			var submatch = arguments[i];
			submatches[--i] = submatch === undefined
				? _elm_lang$core$Maybe$Nothing
				: _elm_lang$core$Maybe$Just(submatch);
		}
		return replacer({
			match: match,
			submatches: _elm_lang$core$Native_List.fromArray(submatches),
			index: arguments[arguments.length - 2],
			number: count
		});
	}
	return string.replace(re, jsReplacer);
}

function split(n, re, str)
{
	n = n.ctor === 'All' ? Infinity : n._0;
	if (n === Infinity)
	{
		return _elm_lang$core$Native_List.fromArray(str.split(re));
	}
	var string = str;
	var result;
	var out = [];
	var start = re.lastIndex;
	var restoreLastIndex = re.lastIndex;
	while (n--)
	{
		if (!(result = re.exec(string))) break;
		out.push(string.slice(start, result.index));
		start = re.lastIndex;
	}
	out.push(string.slice(start));
	re.lastIndex = restoreLastIndex;
	return _elm_lang$core$Native_List.fromArray(out);
}

return {
	regex: regex,
	caseInsensitive: caseInsensitive,
	escape: escape,

	contains: F2(contains),
	find: F3(find),
	replace: F4(replace),
	split: F3(split)
};

}();

var _elm_lang$core$Regex$split = _elm_lang$core$Native_Regex.split;
var _elm_lang$core$Regex$replace = _elm_lang$core$Native_Regex.replace;
var _elm_lang$core$Regex$find = _elm_lang$core$Native_Regex.find;
var _elm_lang$core$Regex$contains = _elm_lang$core$Native_Regex.contains;
var _elm_lang$core$Regex$caseInsensitive = _elm_lang$core$Native_Regex.caseInsensitive;
var _elm_lang$core$Regex$regex = _elm_lang$core$Native_Regex.regex;
var _elm_lang$core$Regex$escape = _elm_lang$core$Native_Regex.escape;
var _elm_lang$core$Regex$Match = F4(
	function (a, b, c, d) {
		return {match: a, submatches: b, index: c, number: d};
	});
var _elm_lang$core$Regex$Regex = {ctor: 'Regex'};
var _elm_lang$core$Regex$AtMost = function (a) {
	return {ctor: 'AtMost', _0: a};
};
var _elm_lang$core$Regex$All = {ctor: 'All'};

var _elm_lang$core$Native_Bitwise = function() {

return {
	and: F2(function and(a, b) { return a & b; }),
	or: F2(function or(a, b) { return a | b; }),
	xor: F2(function xor(a, b) { return a ^ b; }),
	complement: function complement(a) { return ~a; },
	shiftLeftBy: F2(function(offset, a) { return a << offset; }),
	shiftRightBy: F2(function(offset, a) { return a >> offset; }),
	shiftRightZfBy: F2(function(offset, a) { return a >>> offset; })
};

}();

var _elm_lang$core$Bitwise$shiftRightZfBy = _elm_lang$core$Native_Bitwise.shiftRightZfBy;
var _elm_lang$core$Bitwise$shiftRightBy = _elm_lang$core$Native_Bitwise.shiftRightBy;
var _elm_lang$core$Bitwise$shiftLeftBy = _elm_lang$core$Native_Bitwise.shiftLeftBy;
var _elm_lang$core$Bitwise$complement = _elm_lang$core$Native_Bitwise.complement;
var _elm_lang$core$Bitwise$xor = _elm_lang$core$Native_Bitwise.xor;
var _elm_lang$core$Bitwise$or = _elm_lang$core$Native_Bitwise.or;
var _elm_lang$core$Bitwise$and = _elm_lang$core$Native_Bitwise.and;

var _elm_community$string_extra$String_Extra$replacementCodePoint = 65533;
var _elm_community$string_extra$String_Extra$toCodePoints = function (string) {
	var allCodeUnits = A2(
		_elm_lang$core$List$map,
		_elm_lang$core$Char$toCode,
		_elm_lang$core$String$toList(string));
	var combineAndReverse = F2(
		function (codeUnits, accumulated) {
			combineAndReverse:
			while (true) {
				var _p0 = codeUnits;
				if (_p0.ctor === '[]') {
					return accumulated;
				} else {
					var _p4 = _p0._0;
					var _p3 = _p0._1;
					if ((_elm_lang$core$Native_Utils.cmp(_p4, 0) > -1) && (_elm_lang$core$Native_Utils.cmp(_p4, 55295) < 1)) {
						var _v1 = _p3,
							_v2 = {ctor: '::', _0: _p4, _1: accumulated};
						codeUnits = _v1;
						accumulated = _v2;
						continue combineAndReverse;
					} else {
						if ((_elm_lang$core$Native_Utils.cmp(_p4, 55296) > -1) && (_elm_lang$core$Native_Utils.cmp(_p4, 56319) < 1)) {
							var _p1 = _p3;
							if (_p1.ctor === '[]') {
								return {ctor: '::', _0: _elm_community$string_extra$String_Extra$replacementCodePoint, _1: accumulated};
							} else {
								var _p2 = _p1._0;
								if ((_elm_lang$core$Native_Utils.cmp(_p2, 56320) > -1) && (_elm_lang$core$Native_Utils.cmp(_p2, 57343) < 1)) {
									var codePoint = (65536 + ((_p4 - 55296) * 1024)) + (_p2 - 56320);
									var _v4 = _p1._1,
										_v5 = {ctor: '::', _0: codePoint, _1: accumulated};
									codeUnits = _v4;
									accumulated = _v5;
									continue combineAndReverse;
								} else {
									var _v6 = _p3,
										_v7 = {ctor: '::', _0: _elm_community$string_extra$String_Extra$replacementCodePoint, _1: accumulated};
									codeUnits = _v6;
									accumulated = _v7;
									continue combineAndReverse;
								}
							}
						} else {
							if ((_elm_lang$core$Native_Utils.cmp(_p4, 57344) > -1) && (_elm_lang$core$Native_Utils.cmp(_p4, 65535) < 1)) {
								var _v8 = _p3,
									_v9 = {ctor: '::', _0: _p4, _1: accumulated};
								codeUnits = _v8;
								accumulated = _v9;
								continue combineAndReverse;
							} else {
								var _v10 = _p3,
									_v11 = {ctor: '::', _0: _elm_community$string_extra$String_Extra$replacementCodePoint, _1: accumulated};
								codeUnits = _v10;
								accumulated = _v11;
								continue combineAndReverse;
							}
						}
					}
				}
			}
		});
	return _elm_lang$core$List$reverse(
		A2(
			combineAndReverse,
			allCodeUnits,
			{ctor: '[]'}));
};
var _elm_community$string_extra$String_Extra$fromCodePoints = function (allCodePoints) {
	var splitAndReverse = F2(
		function (codePoints, accumulated) {
			splitAndReverse:
			while (true) {
				var _p5 = codePoints;
				if (_p5.ctor === '[]') {
					return accumulated;
				} else {
					var _p7 = _p5._1;
					var _p6 = _p5._0;
					if ((_elm_lang$core$Native_Utils.cmp(_p6, 0) > -1) && (_elm_lang$core$Native_Utils.cmp(_p6, 55295) < 1)) {
						var _v13 = _p7,
							_v14 = {ctor: '::', _0: _p6, _1: accumulated};
						codePoints = _v13;
						accumulated = _v14;
						continue splitAndReverse;
					} else {
						if ((_elm_lang$core$Native_Utils.cmp(_p6, 65536) > -1) && (_elm_lang$core$Native_Utils.cmp(_p6, 1114111) < 1)) {
							var subtracted = _p6 - 65536;
							var leading = (subtracted >> 10) + 55296;
							var trailing = (subtracted & 1023) + 56320;
							var _v15 = _p7,
								_v16 = {
								ctor: '::',
								_0: trailing,
								_1: {ctor: '::', _0: leading, _1: accumulated}
							};
							codePoints = _v15;
							accumulated = _v16;
							continue splitAndReverse;
						} else {
							if ((_elm_lang$core$Native_Utils.cmp(_p6, 57344) > -1) && (_elm_lang$core$Native_Utils.cmp(_p6, 65535) < 1)) {
								var _v17 = _p7,
									_v18 = {ctor: '::', _0: _p6, _1: accumulated};
								codePoints = _v17;
								accumulated = _v18;
								continue splitAndReverse;
							} else {
								var _v19 = _p7,
									_v20 = {ctor: '::', _0: _elm_community$string_extra$String_Extra$replacementCodePoint, _1: accumulated};
								codePoints = _v19;
								accumulated = _v20;
								continue splitAndReverse;
							}
						}
					}
				}
			}
		});
	var allCodeUnits = _elm_lang$core$List$reverse(
		A2(
			splitAndReverse,
			allCodePoints,
			{ctor: '[]'}));
	return _elm_lang$core$String$fromList(
		A2(_elm_lang$core$List$map, _elm_lang$core$Char$fromCode, allCodeUnits));
};
var _elm_community$string_extra$String_Extra$fromFloat = _elm_lang$core$Basics$toString;
var _elm_community$string_extra$String_Extra$fromInt = _elm_lang$core$Basics$toString;
var _elm_community$string_extra$String_Extra$leftOfBack = F2(
	function (pattern, string) {
		return A2(
			_elm_lang$core$Maybe$withDefault,
			'',
			A2(
				_elm_lang$core$Maybe$map,
				A2(_elm_lang$core$Basics$flip, _elm_lang$core$String$left, string),
				_elm_lang$core$List$head(
					_elm_lang$core$List$reverse(
						A2(_elm_lang$core$String$indexes, pattern, string)))));
	});
var _elm_community$string_extra$String_Extra$rightOfBack = F2(
	function (pattern, string) {
		return A2(
			_elm_lang$core$Maybe$withDefault,
			'',
			A2(
				_elm_lang$core$Maybe$map,
				function (_p8) {
					return A3(
						_elm_lang$core$Basics$flip,
						_elm_lang$core$String$dropLeft,
						string,
						A2(
							F2(
								function (x, y) {
									return x + y;
								}),
							_elm_lang$core$String$length(pattern),
							_p8));
				},
				_elm_lang$core$List$head(
					_elm_lang$core$List$reverse(
						A2(_elm_lang$core$String$indexes, pattern, string)))));
	});
var _elm_community$string_extra$String_Extra$firstResultHelp = F2(
	function ($default, list) {
		firstResultHelp:
		while (true) {
			var _p9 = list;
			if (_p9.ctor === '[]') {
				return $default;
			} else {
				if (_p9._0.ctor === 'Just') {
					return _p9._0._0;
				} else {
					var _v22 = $default,
						_v23 = _p9._1;
					$default = _v22;
					list = _v23;
					continue firstResultHelp;
				}
			}
		}
	});
var _elm_community$string_extra$String_Extra$firstResult = function (list) {
	return A2(_elm_community$string_extra$String_Extra$firstResultHelp, '', list);
};
var _elm_community$string_extra$String_Extra$leftOf = F2(
	function (pattern, string) {
		return A2(
			_elm_lang$core$String$join,
			'',
			A2(
				_elm_lang$core$List$map,
				function (_p10) {
					return _elm_community$string_extra$String_Extra$firstResult(
						function (_) {
							return _.submatches;
						}(_p10));
				},
				A3(
					_elm_lang$core$Regex$find,
					_elm_lang$core$Regex$AtMost(1),
					_elm_lang$core$Regex$regex(
						A2(
							_elm_lang$core$Basics_ops['++'],
							'^(.*?)',
							_elm_lang$core$Regex$escape(pattern))),
					string)));
	});
var _elm_community$string_extra$String_Extra$rightOf = F2(
	function (pattern, string) {
		return A2(
			_elm_lang$core$String$join,
			'',
			A2(
				_elm_lang$core$List$map,
				function (_p11) {
					return _elm_community$string_extra$String_Extra$firstResult(
						function (_) {
							return _.submatches;
						}(_p11));
				},
				A3(
					_elm_lang$core$Regex$find,
					_elm_lang$core$Regex$AtMost(1),
					_elm_lang$core$Regex$regex(
						A2(
							_elm_lang$core$Basics_ops['++'],
							_elm_lang$core$Regex$escape(pattern),
							'(.*)$')),
					string)));
	});
var _elm_community$string_extra$String_Extra$stripTags = function (string) {
	return A4(
		_elm_lang$core$Regex$replace,
		_elm_lang$core$Regex$All,
		_elm_lang$core$Regex$regex('<\\/?[^>]+>'),
		_elm_lang$core$Basics$always(''),
		string);
};
var _elm_community$string_extra$String_Extra$toSentenceHelper = F3(
	function (lastPart, sentence, list) {
		toSentenceHelper:
		while (true) {
			var _p12 = list;
			if (_p12.ctor === '[]') {
				return sentence;
			} else {
				if (_p12._1.ctor === '[]') {
					return A2(
						_elm_lang$core$Basics_ops['++'],
						sentence,
						A2(_elm_lang$core$Basics_ops['++'], lastPart, _p12._0));
				} else {
					var _v25 = lastPart,
						_v26 = A2(
						_elm_lang$core$Basics_ops['++'],
						sentence,
						A2(_elm_lang$core$Basics_ops['++'], ', ', _p12._0)),
						_v27 = _p12._1;
					lastPart = _v25;
					sentence = _v26;
					list = _v27;
					continue toSentenceHelper;
				}
			}
		}
	});
var _elm_community$string_extra$String_Extra$toSentenceBaseCase = function (list) {
	var _p13 = list;
	_v28_2:
	do {
		if (_p13.ctor === '::') {
			if (_p13._1.ctor === '[]') {
				return _p13._0;
			} else {
				if (_p13._1._1.ctor === '[]') {
					return A2(
						_elm_lang$core$Basics_ops['++'],
						_p13._0,
						A2(_elm_lang$core$Basics_ops['++'], ' and ', _p13._1._0));
				} else {
					break _v28_2;
				}
			}
		} else {
			break _v28_2;
		}
	} while(false);
	return '';
};
var _elm_community$string_extra$String_Extra$toSentenceOxford = function (list) {
	var _p14 = list;
	if (((_p14.ctor === '::') && (_p14._1.ctor === '::')) && (_p14._1._1.ctor === '::')) {
		return A3(
			_elm_community$string_extra$String_Extra$toSentenceHelper,
			', and ',
			A2(
				_elm_lang$core$Basics_ops['++'],
				_p14._0,
				A2(_elm_lang$core$Basics_ops['++'], ', ', _p14._1._0)),
			{ctor: '::', _0: _p14._1._1._0, _1: _p14._1._1._1});
	} else {
		return _elm_community$string_extra$String_Extra$toSentenceBaseCase(list);
	}
};
var _elm_community$string_extra$String_Extra$toSentence = function (list) {
	var _p15 = list;
	if (((_p15.ctor === '::') && (_p15._1.ctor === '::')) && (_p15._1._1.ctor === '::')) {
		return A3(
			_elm_community$string_extra$String_Extra$toSentenceHelper,
			' and ',
			A2(
				_elm_lang$core$Basics_ops['++'],
				_p15._0,
				A2(_elm_lang$core$Basics_ops['++'], ', ', _p15._1._0)),
			{ctor: '::', _0: _p15._1._1._0, _1: _p15._1._1._1});
	} else {
		return _elm_community$string_extra$String_Extra$toSentenceBaseCase(list);
	}
};
var _elm_community$string_extra$String_Extra$ellipsisWith = F3(
	function (howLong, append, string) {
		return (_elm_lang$core$Native_Utils.cmp(
			_elm_lang$core$String$length(string),
			howLong) < 1) ? string : A2(
			_elm_lang$core$Basics_ops['++'],
			A2(
				_elm_lang$core$String$left,
				howLong - _elm_lang$core$String$length(append),
				string),
			append);
	});
var _elm_community$string_extra$String_Extra$ellipsis = F2(
	function (howLong, string) {
		return A3(_elm_community$string_extra$String_Extra$ellipsisWith, howLong, '...', string);
	});
var _elm_community$string_extra$String_Extra$countOccurrences = F2(
	function (needle, haystack) {
		return (_elm_lang$core$Native_Utils.eq(
			_elm_lang$core$String$length(needle),
			0) || _elm_lang$core$Native_Utils.eq(
			_elm_lang$core$String$length(haystack),
			0)) ? 0 : _elm_lang$core$List$length(
			A2(_elm_lang$core$String$indexes, needle, haystack));
	});
var _elm_community$string_extra$String_Extra$unindent = function (multilineSting) {
	var isNotWhitespace = function ($char) {
		return (!_elm_lang$core$Native_Utils.eq(
			$char,
			_elm_lang$core$Native_Utils.chr(' '))) && (!_elm_lang$core$Native_Utils.eq(
			$char,
			_elm_lang$core$Native_Utils.chr('\t')));
	};
	var countLeadingWhitespace = F2(
		function (count, line) {
			countLeadingWhitespace:
			while (true) {
				var _p16 = _elm_lang$core$String$uncons(line);
				if (_p16.ctor === 'Nothing') {
					return count;
				} else {
					var _p18 = _p16._0._1;
					var _p17 = _p16._0._0;
					switch (_p17.valueOf()) {
						case ' ':
							var _v33 = count + 1,
								_v34 = _p18;
							count = _v33;
							line = _v34;
							continue countLeadingWhitespace;
						case '\t':
							var _v35 = count + 1,
								_v36 = _p18;
							count = _v35;
							line = _v36;
							continue countLeadingWhitespace;
						default:
							return count;
					}
				}
			}
		});
	var lines = _elm_lang$core$String$lines(multilineSting);
	var minLead = A2(
		_elm_lang$core$Maybe$withDefault,
		0,
		_elm_lang$core$List$minimum(
			A2(
				_elm_lang$core$List$map,
				countLeadingWhitespace(0),
				A2(
					_elm_lang$core$List$filter,
					_elm_lang$core$String$any(isNotWhitespace),
					lines))));
	return A2(
		_elm_lang$core$String$join,
		'\n',
		A2(
			_elm_lang$core$List$map,
			_elm_lang$core$String$dropLeft(minLead),
			lines));
};
var _elm_community$string_extra$String_Extra$dasherize = function (string) {
	return _elm_lang$core$String$toLower(
		A4(
			_elm_lang$core$Regex$replace,
			_elm_lang$core$Regex$All,
			_elm_lang$core$Regex$regex('[_-\\s]+'),
			_elm_lang$core$Basics$always('-'),
			A4(
				_elm_lang$core$Regex$replace,
				_elm_lang$core$Regex$All,
				_elm_lang$core$Regex$regex('([A-Z])'),
				function (_p19) {
					return A2(
						_elm_lang$core$String$append,
						'-',
						function (_) {
							return _.match;
						}(_p19));
				},
				_elm_lang$core$String$trim(string))));
};
var _elm_community$string_extra$String_Extra$underscored = function (string) {
	return _elm_lang$core$String$toLower(
		A4(
			_elm_lang$core$Regex$replace,
			_elm_lang$core$Regex$All,
			_elm_lang$core$Regex$regex('[_-\\s]+'),
			_elm_lang$core$Basics$always('_'),
			A4(
				_elm_lang$core$Regex$replace,
				_elm_lang$core$Regex$All,
				_elm_lang$core$Regex$regex('([a-z\\d])([A-Z]+)'),
				function (_p20) {
					return A2(
						_elm_lang$core$String$join,
						'_',
						A2(
							_elm_lang$core$List$filterMap,
							_elm_lang$core$Basics$identity,
							function (_) {
								return _.submatches;
							}(_p20)));
				},
				_elm_lang$core$String$trim(string))));
};
var _elm_community$string_extra$String_Extra$unsurround = F2(
	function (wrap, string) {
		if (A2(_elm_lang$core$String$startsWith, wrap, string) && A2(_elm_lang$core$String$endsWith, wrap, string)) {
			var length = _elm_lang$core$String$length(wrap);
			return A2(
				_elm_lang$core$String$dropRight,
				length,
				A2(_elm_lang$core$String$dropLeft, length, string));
		} else {
			return string;
		}
	});
var _elm_community$string_extra$String_Extra$unquote = function (string) {
	return A2(_elm_community$string_extra$String_Extra$unsurround, '\"', string);
};
var _elm_community$string_extra$String_Extra$surround = F2(
	function (wrap, string) {
		return A2(
			_elm_lang$core$Basics_ops['++'],
			wrap,
			A2(_elm_lang$core$Basics_ops['++'], string, wrap));
	});
var _elm_community$string_extra$String_Extra$quote = function (string) {
	return A2(_elm_community$string_extra$String_Extra$surround, '\"', string);
};
var _elm_community$string_extra$String_Extra$camelize = function (string) {
	return A4(
		_elm_lang$core$Regex$replace,
		_elm_lang$core$Regex$All,
		_elm_lang$core$Regex$regex('[-_\\s]+(.)?'),
		function (_p21) {
			var _p22 = _p21;
			var _p23 = _p22.submatches;
			if ((_p23.ctor === '::') && (_p23._0.ctor === 'Just')) {
				return _elm_lang$core$String$toUpper(_p23._0._0);
			} else {
				return '';
			}
		},
		_elm_lang$core$String$trim(string));
};
var _elm_community$string_extra$String_Extra$isBlank = function (string) {
	return A2(
		_elm_lang$core$Regex$contains,
		_elm_lang$core$Regex$regex('^\\s*$'),
		string);
};
var _elm_community$string_extra$String_Extra$clean = function (string) {
	return _elm_lang$core$String$trim(
		A4(
			_elm_lang$core$Regex$replace,
			_elm_lang$core$Regex$All,
			_elm_lang$core$Regex$regex('\\s\\s+'),
			_elm_lang$core$Basics$always(' '),
			string));
};
var _elm_community$string_extra$String_Extra$softBreakRegexp = function (width) {
	return _elm_lang$core$Regex$regex(
		A2(
			_elm_lang$core$Basics_ops['++'],
			'.{1,',
			A2(
				_elm_lang$core$Basics_ops['++'],
				_elm_lang$core$Basics$toString(width),
				'}(\\s+|$)|\\S+?(\\s+|$)')));
};
var _elm_community$string_extra$String_Extra$softEllipsis = F2(
	function (howLong, string) {
		return (_elm_lang$core$Native_Utils.cmp(
			_elm_lang$core$String$length(string),
			howLong) < 1) ? string : A3(
			_elm_lang$core$Basics$flip,
			_elm_lang$core$String$append,
			'...',
			A4(
				_elm_lang$core$Regex$replace,
				_elm_lang$core$Regex$All,
				_elm_lang$core$Regex$regex('([\\.,;:\\s])+$'),
				_elm_lang$core$Basics$always(''),
				A2(
					_elm_lang$core$String$join,
					'',
					A2(
						_elm_lang$core$List$map,
						function (_) {
							return _.match;
						},
						A3(
							_elm_lang$core$Regex$find,
							_elm_lang$core$Regex$AtMost(1),
							_elm_community$string_extra$String_Extra$softBreakRegexp(howLong),
							string)))));
	});
var _elm_community$string_extra$String_Extra$softBreak = F2(
	function (width, string) {
		return (_elm_lang$core$Native_Utils.cmp(width, 0) < 1) ? {ctor: '[]'} : A2(
			_elm_lang$core$List$map,
			function (_) {
				return _.match;
			},
			A3(
				_elm_lang$core$Regex$find,
				_elm_lang$core$Regex$All,
				_elm_community$string_extra$String_Extra$softBreakRegexp(width),
				string));
	});
var _elm_community$string_extra$String_Extra$softWrapWith = F3(
	function (width, separator, string) {
		return A2(
			_elm_lang$core$String$join,
			separator,
			A2(_elm_community$string_extra$String_Extra$softBreak, width, string));
	});
var _elm_community$string_extra$String_Extra$softWrap = F2(
	function (width, string) {
		return A3(_elm_community$string_extra$String_Extra$softWrapWith, width, '\n', string);
	});
var _elm_community$string_extra$String_Extra$breaker = F3(
	function (width, string, acc) {
		breaker:
		while (true) {
			var _p24 = string;
			if (_p24 === '') {
				return _elm_lang$core$List$reverse(acc);
			} else {
				var _v40 = width,
					_v41 = A2(_elm_lang$core$String$dropLeft, width, string),
					_v42 = {
					ctor: '::',
					_0: A3(_elm_lang$core$String$slice, 0, width, string),
					_1: acc
				};
				width = _v40;
				string = _v41;
				acc = _v42;
				continue breaker;
			}
		}
	});
var _elm_community$string_extra$String_Extra$break = F2(
	function (width, string) {
		return (_elm_lang$core$Native_Utils.eq(width, 0) || _elm_lang$core$Native_Utils.eq(string, '')) ? {
			ctor: '::',
			_0: string,
			_1: {ctor: '[]'}
		} : A3(
			_elm_community$string_extra$String_Extra$breaker,
			width,
			string,
			{ctor: '[]'});
	});
var _elm_community$string_extra$String_Extra$wrapWith = F3(
	function (width, separator, string) {
		return A2(
			_elm_lang$core$String$join,
			separator,
			A2(_elm_community$string_extra$String_Extra$break, width, string));
	});
var _elm_community$string_extra$String_Extra$wrap = F2(
	function (width, string) {
		return A3(_elm_community$string_extra$String_Extra$wrapWith, width, '\n', string);
	});
var _elm_community$string_extra$String_Extra$replaceSlice = F4(
	function (substitution, start, end, string) {
		return A2(
			_elm_lang$core$Basics_ops['++'],
			A3(_elm_lang$core$String$slice, 0, start, string),
			A2(
				_elm_lang$core$Basics_ops['++'],
				substitution,
				A3(
					_elm_lang$core$String$slice,
					end,
					_elm_lang$core$String$length(string),
					string)));
	});
var _elm_community$string_extra$String_Extra$insertAt = F3(
	function (insert, pos, string) {
		return A4(_elm_community$string_extra$String_Extra$replaceSlice, insert, pos, pos, string);
	});
var _elm_community$string_extra$String_Extra$replace = F3(
	function (search, substitution, string) {
		return A4(
			_elm_lang$core$Regex$replace,
			_elm_lang$core$Regex$All,
			_elm_lang$core$Regex$regex(
				_elm_lang$core$Regex$escape(search)),
			function (_p25) {
				return substitution;
			},
			string);
	});
var _elm_community$string_extra$String_Extra$changeCase = F2(
	function (mutator, word) {
		return A2(
			_elm_lang$core$Maybe$withDefault,
			'',
			A2(
				_elm_lang$core$Maybe$map,
				function (_p26) {
					var _p27 = _p26;
					return A2(
						_elm_lang$core$String$cons,
						mutator(_p27._0),
						_p27._1);
				},
				_elm_lang$core$String$uncons(word)));
	});
var _elm_community$string_extra$String_Extra$toSentenceCase = function (word) {
	return A2(_elm_community$string_extra$String_Extra$changeCase, _elm_lang$core$Char$toUpper, word);
};
var _elm_community$string_extra$String_Extra$toTitleCase = function (ws) {
	var uppercaseMatch = A3(
		_elm_lang$core$Regex$replace,
		_elm_lang$core$Regex$All,
		_elm_lang$core$Regex$regex('\\w+'),
		function (_p28) {
			return _elm_community$string_extra$String_Extra$toSentenceCase(
				function (_) {
					return _.match;
				}(_p28));
		});
	return A4(
		_elm_lang$core$Regex$replace,
		_elm_lang$core$Regex$All,
		_elm_lang$core$Regex$regex('^([a-z])|\\s+([a-z])'),
		function (_p29) {
			return uppercaseMatch(
				function (_) {
					return _.match;
				}(_p29));
		},
		ws);
};
var _elm_community$string_extra$String_Extra$classify = function (string) {
	return _elm_community$string_extra$String_Extra$toSentenceCase(
		A3(
			_elm_community$string_extra$String_Extra$replace,
			' ',
			'',
			_elm_community$string_extra$String_Extra$camelize(
				A4(
					_elm_lang$core$Regex$replace,
					_elm_lang$core$Regex$All,
					_elm_lang$core$Regex$regex('[\\W_]'),
					_elm_lang$core$Basics$always(' '),
					string))));
};
var _elm_community$string_extra$String_Extra$humanize = function (string) {
	return _elm_community$string_extra$String_Extra$toSentenceCase(
		_elm_lang$core$String$toLower(
			_elm_lang$core$String$trim(
				A4(
					_elm_lang$core$Regex$replace,
					_elm_lang$core$Regex$All,
					_elm_lang$core$Regex$regex('_id$|[-_\\s]+'),
					_elm_lang$core$Basics$always(' '),
					A4(
						_elm_lang$core$Regex$replace,
						_elm_lang$core$Regex$All,
						_elm_lang$core$Regex$regex('[A-Z]'),
						function (_p30) {
							return A2(
								_elm_lang$core$String$append,
								'-',
								function (_) {
									return _.match;
								}(_p30));
						},
						string)))));
};
var _elm_community$string_extra$String_Extra$decapitalize = function (word) {
	return A2(_elm_community$string_extra$String_Extra$changeCase, _elm_lang$core$Char$toLower, word);
};

var _elm_lang$animation_frame$Native_AnimationFrame = function()
{

function create()
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		var id = requestAnimationFrame(function() {
			callback(_elm_lang$core$Native_Scheduler.succeed(Date.now()));
		});

		return function() {
			cancelAnimationFrame(id);
		};
	});
}

return {
	create: create
};

}();

var _elm_lang$core$Task$onError = _elm_lang$core$Native_Scheduler.onError;
var _elm_lang$core$Task$andThen = _elm_lang$core$Native_Scheduler.andThen;
var _elm_lang$core$Task$spawnCmd = F2(
	function (router, _p0) {
		var _p1 = _p0;
		return _elm_lang$core$Native_Scheduler.spawn(
			A2(
				_elm_lang$core$Task$andThen,
				_elm_lang$core$Platform$sendToApp(router),
				_p1._0));
	});
var _elm_lang$core$Task$fail = _elm_lang$core$Native_Scheduler.fail;
var _elm_lang$core$Task$mapError = F2(
	function (convert, task) {
		return A2(
			_elm_lang$core$Task$onError,
			function (_p2) {
				return _elm_lang$core$Task$fail(
					convert(_p2));
			},
			task);
	});
var _elm_lang$core$Task$succeed = _elm_lang$core$Native_Scheduler.succeed;
var _elm_lang$core$Task$map = F2(
	function (func, taskA) {
		return A2(
			_elm_lang$core$Task$andThen,
			function (a) {
				return _elm_lang$core$Task$succeed(
					func(a));
			},
			taskA);
	});
var _elm_lang$core$Task$map2 = F3(
	function (func, taskA, taskB) {
		return A2(
			_elm_lang$core$Task$andThen,
			function (a) {
				return A2(
					_elm_lang$core$Task$andThen,
					function (b) {
						return _elm_lang$core$Task$succeed(
							A2(func, a, b));
					},
					taskB);
			},
			taskA);
	});
var _elm_lang$core$Task$map3 = F4(
	function (func, taskA, taskB, taskC) {
		return A2(
			_elm_lang$core$Task$andThen,
			function (a) {
				return A2(
					_elm_lang$core$Task$andThen,
					function (b) {
						return A2(
							_elm_lang$core$Task$andThen,
							function (c) {
								return _elm_lang$core$Task$succeed(
									A3(func, a, b, c));
							},
							taskC);
					},
					taskB);
			},
			taskA);
	});
var _elm_lang$core$Task$map4 = F5(
	function (func, taskA, taskB, taskC, taskD) {
		return A2(
			_elm_lang$core$Task$andThen,
			function (a) {
				return A2(
					_elm_lang$core$Task$andThen,
					function (b) {
						return A2(
							_elm_lang$core$Task$andThen,
							function (c) {
								return A2(
									_elm_lang$core$Task$andThen,
									function (d) {
										return _elm_lang$core$Task$succeed(
											A4(func, a, b, c, d));
									},
									taskD);
							},
							taskC);
					},
					taskB);
			},
			taskA);
	});
var _elm_lang$core$Task$map5 = F6(
	function (func, taskA, taskB, taskC, taskD, taskE) {
		return A2(
			_elm_lang$core$Task$andThen,
			function (a) {
				return A2(
					_elm_lang$core$Task$andThen,
					function (b) {
						return A2(
							_elm_lang$core$Task$andThen,
							function (c) {
								return A2(
									_elm_lang$core$Task$andThen,
									function (d) {
										return A2(
											_elm_lang$core$Task$andThen,
											function (e) {
												return _elm_lang$core$Task$succeed(
													A5(func, a, b, c, d, e));
											},
											taskE);
									},
									taskD);
							},
							taskC);
					},
					taskB);
			},
			taskA);
	});
var _elm_lang$core$Task$sequence = function (tasks) {
	var _p3 = tasks;
	if (_p3.ctor === '[]') {
		return _elm_lang$core$Task$succeed(
			{ctor: '[]'});
	} else {
		return A3(
			_elm_lang$core$Task$map2,
			F2(
				function (x, y) {
					return {ctor: '::', _0: x, _1: y};
				}),
			_p3._0,
			_elm_lang$core$Task$sequence(_p3._1));
	}
};
var _elm_lang$core$Task$onEffects = F3(
	function (router, commands, state) {
		return A2(
			_elm_lang$core$Task$map,
			function (_p4) {
				return {ctor: '_Tuple0'};
			},
			_elm_lang$core$Task$sequence(
				A2(
					_elm_lang$core$List$map,
					_elm_lang$core$Task$spawnCmd(router),
					commands)));
	});
var _elm_lang$core$Task$init = _elm_lang$core$Task$succeed(
	{ctor: '_Tuple0'});
var _elm_lang$core$Task$onSelfMsg = F3(
	function (_p7, _p6, _p5) {
		return _elm_lang$core$Task$succeed(
			{ctor: '_Tuple0'});
	});
var _elm_lang$core$Task$command = _elm_lang$core$Native_Platform.leaf('Task');
var _elm_lang$core$Task$Perform = function (a) {
	return {ctor: 'Perform', _0: a};
};
var _elm_lang$core$Task$perform = F2(
	function (toMessage, task) {
		return _elm_lang$core$Task$command(
			_elm_lang$core$Task$Perform(
				A2(_elm_lang$core$Task$map, toMessage, task)));
	});
var _elm_lang$core$Task$attempt = F2(
	function (resultToMessage, task) {
		return _elm_lang$core$Task$command(
			_elm_lang$core$Task$Perform(
				A2(
					_elm_lang$core$Task$onError,
					function (_p8) {
						return _elm_lang$core$Task$succeed(
							resultToMessage(
								_elm_lang$core$Result$Err(_p8)));
					},
					A2(
						_elm_lang$core$Task$andThen,
						function (_p9) {
							return _elm_lang$core$Task$succeed(
								resultToMessage(
									_elm_lang$core$Result$Ok(_p9)));
						},
						task))));
	});
var _elm_lang$core$Task$cmdMap = F2(
	function (tagger, _p10) {
		var _p11 = _p10;
		return _elm_lang$core$Task$Perform(
			A2(_elm_lang$core$Task$map, tagger, _p11._0));
	});
_elm_lang$core$Native_Platform.effectManagers['Task'] = {pkg: 'elm-lang/core', init: _elm_lang$core$Task$init, onEffects: _elm_lang$core$Task$onEffects, onSelfMsg: _elm_lang$core$Task$onSelfMsg, tag: 'cmd', cmdMap: _elm_lang$core$Task$cmdMap};

//import Native.Scheduler //

var _elm_lang$core$Native_Time = function() {

var now = _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
{
	callback(_elm_lang$core$Native_Scheduler.succeed(Date.now()));
});

function setInterval_(interval, task)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		var id = setInterval(function() {
			_elm_lang$core$Native_Scheduler.rawSpawn(task);
		}, interval);

		return function() { clearInterval(id); };
	});
}

return {
	now: now,
	setInterval_: F2(setInterval_)
};

}();
var _elm_lang$core$Time$setInterval = _elm_lang$core$Native_Time.setInterval_;
var _elm_lang$core$Time$spawnHelp = F3(
	function (router, intervals, processes) {
		var _p0 = intervals;
		if (_p0.ctor === '[]') {
			return _elm_lang$core$Task$succeed(processes);
		} else {
			var _p1 = _p0._0;
			var spawnRest = function (id) {
				return A3(
					_elm_lang$core$Time$spawnHelp,
					router,
					_p0._1,
					A3(_elm_lang$core$Dict$insert, _p1, id, processes));
			};
			var spawnTimer = _elm_lang$core$Native_Scheduler.spawn(
				A2(
					_elm_lang$core$Time$setInterval,
					_p1,
					A2(_elm_lang$core$Platform$sendToSelf, router, _p1)));
			return A2(_elm_lang$core$Task$andThen, spawnRest, spawnTimer);
		}
	});
var _elm_lang$core$Time$addMySub = F2(
	function (_p2, state) {
		var _p3 = _p2;
		var _p6 = _p3._1;
		var _p5 = _p3._0;
		var _p4 = A2(_elm_lang$core$Dict$get, _p5, state);
		if (_p4.ctor === 'Nothing') {
			return A3(
				_elm_lang$core$Dict$insert,
				_p5,
				{
					ctor: '::',
					_0: _p6,
					_1: {ctor: '[]'}
				},
				state);
		} else {
			return A3(
				_elm_lang$core$Dict$insert,
				_p5,
				{ctor: '::', _0: _p6, _1: _p4._0},
				state);
		}
	});
var _elm_lang$core$Time$inMilliseconds = function (t) {
	return t;
};
var _elm_lang$core$Time$millisecond = 1;
var _elm_lang$core$Time$second = 1000 * _elm_lang$core$Time$millisecond;
var _elm_lang$core$Time$minute = 60 * _elm_lang$core$Time$second;
var _elm_lang$core$Time$hour = 60 * _elm_lang$core$Time$minute;
var _elm_lang$core$Time$inHours = function (t) {
	return t / _elm_lang$core$Time$hour;
};
var _elm_lang$core$Time$inMinutes = function (t) {
	return t / _elm_lang$core$Time$minute;
};
var _elm_lang$core$Time$inSeconds = function (t) {
	return t / _elm_lang$core$Time$second;
};
var _elm_lang$core$Time$now = _elm_lang$core$Native_Time.now;
var _elm_lang$core$Time$onSelfMsg = F3(
	function (router, interval, state) {
		var _p7 = A2(_elm_lang$core$Dict$get, interval, state.taggers);
		if (_p7.ctor === 'Nothing') {
			return _elm_lang$core$Task$succeed(state);
		} else {
			var tellTaggers = function (time) {
				return _elm_lang$core$Task$sequence(
					A2(
						_elm_lang$core$List$map,
						function (tagger) {
							return A2(
								_elm_lang$core$Platform$sendToApp,
								router,
								tagger(time));
						},
						_p7._0));
			};
			return A2(
				_elm_lang$core$Task$andThen,
				function (_p8) {
					return _elm_lang$core$Task$succeed(state);
				},
				A2(_elm_lang$core$Task$andThen, tellTaggers, _elm_lang$core$Time$now));
		}
	});
var _elm_lang$core$Time$subscription = _elm_lang$core$Native_Platform.leaf('Time');
var _elm_lang$core$Time$State = F2(
	function (a, b) {
		return {taggers: a, processes: b};
	});
var _elm_lang$core$Time$init = _elm_lang$core$Task$succeed(
	A2(_elm_lang$core$Time$State, _elm_lang$core$Dict$empty, _elm_lang$core$Dict$empty));
var _elm_lang$core$Time$onEffects = F3(
	function (router, subs, _p9) {
		var _p10 = _p9;
		var rightStep = F3(
			function (_p12, id, _p11) {
				var _p13 = _p11;
				return {
					ctor: '_Tuple3',
					_0: _p13._0,
					_1: _p13._1,
					_2: A2(
						_elm_lang$core$Task$andThen,
						function (_p14) {
							return _p13._2;
						},
						_elm_lang$core$Native_Scheduler.kill(id))
				};
			});
		var bothStep = F4(
			function (interval, taggers, id, _p15) {
				var _p16 = _p15;
				return {
					ctor: '_Tuple3',
					_0: _p16._0,
					_1: A3(_elm_lang$core$Dict$insert, interval, id, _p16._1),
					_2: _p16._2
				};
			});
		var leftStep = F3(
			function (interval, taggers, _p17) {
				var _p18 = _p17;
				return {
					ctor: '_Tuple3',
					_0: {ctor: '::', _0: interval, _1: _p18._0},
					_1: _p18._1,
					_2: _p18._2
				};
			});
		var newTaggers = A3(_elm_lang$core$List$foldl, _elm_lang$core$Time$addMySub, _elm_lang$core$Dict$empty, subs);
		var _p19 = A6(
			_elm_lang$core$Dict$merge,
			leftStep,
			bothStep,
			rightStep,
			newTaggers,
			_p10.processes,
			{
				ctor: '_Tuple3',
				_0: {ctor: '[]'},
				_1: _elm_lang$core$Dict$empty,
				_2: _elm_lang$core$Task$succeed(
					{ctor: '_Tuple0'})
			});
		var spawnList = _p19._0;
		var existingDict = _p19._1;
		var killTask = _p19._2;
		return A2(
			_elm_lang$core$Task$andThen,
			function (newProcesses) {
				return _elm_lang$core$Task$succeed(
					A2(_elm_lang$core$Time$State, newTaggers, newProcesses));
			},
			A2(
				_elm_lang$core$Task$andThen,
				function (_p20) {
					return A3(_elm_lang$core$Time$spawnHelp, router, spawnList, existingDict);
				},
				killTask));
	});
var _elm_lang$core$Time$Every = F2(
	function (a, b) {
		return {ctor: 'Every', _0: a, _1: b};
	});
var _elm_lang$core$Time$every = F2(
	function (interval, tagger) {
		return _elm_lang$core$Time$subscription(
			A2(_elm_lang$core$Time$Every, interval, tagger));
	});
var _elm_lang$core$Time$subMap = F2(
	function (f, _p21) {
		var _p22 = _p21;
		return A2(
			_elm_lang$core$Time$Every,
			_p22._0,
			function (_p23) {
				return f(
					_p22._1(_p23));
			});
	});
_elm_lang$core$Native_Platform.effectManagers['Time'] = {pkg: 'elm-lang/core', init: _elm_lang$core$Time$init, onEffects: _elm_lang$core$Time$onEffects, onSelfMsg: _elm_lang$core$Time$onSelfMsg, tag: 'sub', subMap: _elm_lang$core$Time$subMap};

var _elm_lang$core$Process$kill = _elm_lang$core$Native_Scheduler.kill;
var _elm_lang$core$Process$sleep = _elm_lang$core$Native_Scheduler.sleep;
var _elm_lang$core$Process$spawn = _elm_lang$core$Native_Scheduler.spawn;

var _elm_lang$animation_frame$AnimationFrame$rAF = _elm_lang$animation_frame$Native_AnimationFrame.create(
	{ctor: '_Tuple0'});
var _elm_lang$animation_frame$AnimationFrame$subscription = _elm_lang$core$Native_Platform.leaf('AnimationFrame');
var _elm_lang$animation_frame$AnimationFrame$State = F3(
	function (a, b, c) {
		return {subs: a, request: b, oldTime: c};
	});
var _elm_lang$animation_frame$AnimationFrame$init = _elm_lang$core$Task$succeed(
	A3(
		_elm_lang$animation_frame$AnimationFrame$State,
		{ctor: '[]'},
		_elm_lang$core$Maybe$Nothing,
		0));
var _elm_lang$animation_frame$AnimationFrame$onEffects = F3(
	function (router, subs, _p0) {
		var _p1 = _p0;
		var _p5 = _p1.request;
		var _p4 = _p1.oldTime;
		var _p2 = {ctor: '_Tuple2', _0: _p5, _1: subs};
		if (_p2._0.ctor === 'Nothing') {
			if (_p2._1.ctor === '[]') {
				return _elm_lang$core$Task$succeed(
					A3(
						_elm_lang$animation_frame$AnimationFrame$State,
						{ctor: '[]'},
						_elm_lang$core$Maybe$Nothing,
						_p4));
			} else {
				return A2(
					_elm_lang$core$Task$andThen,
					function (pid) {
						return A2(
							_elm_lang$core$Task$andThen,
							function (time) {
								return _elm_lang$core$Task$succeed(
									A3(
										_elm_lang$animation_frame$AnimationFrame$State,
										subs,
										_elm_lang$core$Maybe$Just(pid),
										time));
							},
							_elm_lang$core$Time$now);
					},
					_elm_lang$core$Process$spawn(
						A2(
							_elm_lang$core$Task$andThen,
							_elm_lang$core$Platform$sendToSelf(router),
							_elm_lang$animation_frame$AnimationFrame$rAF)));
			}
		} else {
			if (_p2._1.ctor === '[]') {
				return A2(
					_elm_lang$core$Task$andThen,
					function (_p3) {
						return _elm_lang$core$Task$succeed(
							A3(
								_elm_lang$animation_frame$AnimationFrame$State,
								{ctor: '[]'},
								_elm_lang$core$Maybe$Nothing,
								_p4));
					},
					_elm_lang$core$Process$kill(_p2._0._0));
			} else {
				return _elm_lang$core$Task$succeed(
					A3(_elm_lang$animation_frame$AnimationFrame$State, subs, _p5, _p4));
			}
		}
	});
var _elm_lang$animation_frame$AnimationFrame$onSelfMsg = F3(
	function (router, newTime, _p6) {
		var _p7 = _p6;
		var _p10 = _p7.subs;
		var diff = newTime - _p7.oldTime;
		var send = function (sub) {
			var _p8 = sub;
			if (_p8.ctor === 'Time') {
				return A2(
					_elm_lang$core$Platform$sendToApp,
					router,
					_p8._0(newTime));
			} else {
				return A2(
					_elm_lang$core$Platform$sendToApp,
					router,
					_p8._0(diff));
			}
		};
		return A2(
			_elm_lang$core$Task$andThen,
			function (pid) {
				return A2(
					_elm_lang$core$Task$andThen,
					function (_p9) {
						return _elm_lang$core$Task$succeed(
							A3(
								_elm_lang$animation_frame$AnimationFrame$State,
								_p10,
								_elm_lang$core$Maybe$Just(pid),
								newTime));
					},
					_elm_lang$core$Task$sequence(
						A2(_elm_lang$core$List$map, send, _p10)));
			},
			_elm_lang$core$Process$spawn(
				A2(
					_elm_lang$core$Task$andThen,
					_elm_lang$core$Platform$sendToSelf(router),
					_elm_lang$animation_frame$AnimationFrame$rAF)));
	});
var _elm_lang$animation_frame$AnimationFrame$Diff = function (a) {
	return {ctor: 'Diff', _0: a};
};
var _elm_lang$animation_frame$AnimationFrame$diffs = function (tagger) {
	return _elm_lang$animation_frame$AnimationFrame$subscription(
		_elm_lang$animation_frame$AnimationFrame$Diff(tagger));
};
var _elm_lang$animation_frame$AnimationFrame$Time = function (a) {
	return {ctor: 'Time', _0: a};
};
var _elm_lang$animation_frame$AnimationFrame$times = function (tagger) {
	return _elm_lang$animation_frame$AnimationFrame$subscription(
		_elm_lang$animation_frame$AnimationFrame$Time(tagger));
};
var _elm_lang$animation_frame$AnimationFrame$subMap = F2(
	function (func, sub) {
		var _p11 = sub;
		if (_p11.ctor === 'Time') {
			return _elm_lang$animation_frame$AnimationFrame$Time(
				function (_p12) {
					return func(
						_p11._0(_p12));
				});
		} else {
			return _elm_lang$animation_frame$AnimationFrame$Diff(
				function (_p13) {
					return func(
						_p11._0(_p13));
				});
		}
	});
_elm_lang$core$Native_Platform.effectManagers['AnimationFrame'] = {pkg: 'elm-lang/animation-frame', init: _elm_lang$animation_frame$AnimationFrame$init, onEffects: _elm_lang$animation_frame$AnimationFrame$onEffects, onSelfMsg: _elm_lang$animation_frame$AnimationFrame$onSelfMsg, tag: 'sub', subMap: _elm_lang$animation_frame$AnimationFrame$subMap};

var _elm_lang$core$Color$fmod = F2(
	function (f, n) {
		var integer = _elm_lang$core$Basics$floor(f);
		return (_elm_lang$core$Basics$toFloat(
			A2(_elm_lang$core$Basics_ops['%'], integer, n)) + f) - _elm_lang$core$Basics$toFloat(integer);
	});
var _elm_lang$core$Color$rgbToHsl = F3(
	function (red, green, blue) {
		var b = _elm_lang$core$Basics$toFloat(blue) / 255;
		var g = _elm_lang$core$Basics$toFloat(green) / 255;
		var r = _elm_lang$core$Basics$toFloat(red) / 255;
		var cMax = A2(
			_elm_lang$core$Basics$max,
			A2(_elm_lang$core$Basics$max, r, g),
			b);
		var cMin = A2(
			_elm_lang$core$Basics$min,
			A2(_elm_lang$core$Basics$min, r, g),
			b);
		var c = cMax - cMin;
		var lightness = (cMax + cMin) / 2;
		var saturation = _elm_lang$core$Native_Utils.eq(lightness, 0) ? 0 : (c / (1 - _elm_lang$core$Basics$abs((2 * lightness) - 1)));
		var hue = _elm_lang$core$Basics$degrees(60) * (_elm_lang$core$Native_Utils.eq(cMax, r) ? A2(_elm_lang$core$Color$fmod, (g - b) / c, 6) : (_elm_lang$core$Native_Utils.eq(cMax, g) ? (((b - r) / c) + 2) : (((r - g) / c) + 4)));
		return {ctor: '_Tuple3', _0: hue, _1: saturation, _2: lightness};
	});
var _elm_lang$core$Color$hslToRgb = F3(
	function (hue, saturation, lightness) {
		var normHue = hue / _elm_lang$core$Basics$degrees(60);
		var chroma = (1 - _elm_lang$core$Basics$abs((2 * lightness) - 1)) * saturation;
		var x = chroma * (1 - _elm_lang$core$Basics$abs(
			A2(_elm_lang$core$Color$fmod, normHue, 2) - 1));
		var _p0 = (_elm_lang$core$Native_Utils.cmp(normHue, 0) < 0) ? {ctor: '_Tuple3', _0: 0, _1: 0, _2: 0} : ((_elm_lang$core$Native_Utils.cmp(normHue, 1) < 0) ? {ctor: '_Tuple3', _0: chroma, _1: x, _2: 0} : ((_elm_lang$core$Native_Utils.cmp(normHue, 2) < 0) ? {ctor: '_Tuple3', _0: x, _1: chroma, _2: 0} : ((_elm_lang$core$Native_Utils.cmp(normHue, 3) < 0) ? {ctor: '_Tuple3', _0: 0, _1: chroma, _2: x} : ((_elm_lang$core$Native_Utils.cmp(normHue, 4) < 0) ? {ctor: '_Tuple3', _0: 0, _1: x, _2: chroma} : ((_elm_lang$core$Native_Utils.cmp(normHue, 5) < 0) ? {ctor: '_Tuple3', _0: x, _1: 0, _2: chroma} : ((_elm_lang$core$Native_Utils.cmp(normHue, 6) < 0) ? {ctor: '_Tuple3', _0: chroma, _1: 0, _2: x} : {ctor: '_Tuple3', _0: 0, _1: 0, _2: 0}))))));
		var r = _p0._0;
		var g = _p0._1;
		var b = _p0._2;
		var m = lightness - (chroma / 2);
		return {ctor: '_Tuple3', _0: r + m, _1: g + m, _2: b + m};
	});
var _elm_lang$core$Color$toRgb = function (color) {
	var _p1 = color;
	if (_p1.ctor === 'RGBA') {
		return {red: _p1._0, green: _p1._1, blue: _p1._2, alpha: _p1._3};
	} else {
		var _p2 = A3(_elm_lang$core$Color$hslToRgb, _p1._0, _p1._1, _p1._2);
		var r = _p2._0;
		var g = _p2._1;
		var b = _p2._2;
		return {
			red: _elm_lang$core$Basics$round(255 * r),
			green: _elm_lang$core$Basics$round(255 * g),
			blue: _elm_lang$core$Basics$round(255 * b),
			alpha: _p1._3
		};
	}
};
var _elm_lang$core$Color$toHsl = function (color) {
	var _p3 = color;
	if (_p3.ctor === 'HSLA') {
		return {hue: _p3._0, saturation: _p3._1, lightness: _p3._2, alpha: _p3._3};
	} else {
		var _p4 = A3(_elm_lang$core$Color$rgbToHsl, _p3._0, _p3._1, _p3._2);
		var h = _p4._0;
		var s = _p4._1;
		var l = _p4._2;
		return {hue: h, saturation: s, lightness: l, alpha: _p3._3};
	}
};
var _elm_lang$core$Color$HSLA = F4(
	function (a, b, c, d) {
		return {ctor: 'HSLA', _0: a, _1: b, _2: c, _3: d};
	});
var _elm_lang$core$Color$hsla = F4(
	function (hue, saturation, lightness, alpha) {
		return A4(
			_elm_lang$core$Color$HSLA,
			hue - _elm_lang$core$Basics$turns(
				_elm_lang$core$Basics$toFloat(
					_elm_lang$core$Basics$floor(hue / (2 * _elm_lang$core$Basics$pi)))),
			saturation,
			lightness,
			alpha);
	});
var _elm_lang$core$Color$hsl = F3(
	function (hue, saturation, lightness) {
		return A4(_elm_lang$core$Color$hsla, hue, saturation, lightness, 1);
	});
var _elm_lang$core$Color$complement = function (color) {
	var _p5 = color;
	if (_p5.ctor === 'HSLA') {
		return A4(
			_elm_lang$core$Color$hsla,
			_p5._0 + _elm_lang$core$Basics$degrees(180),
			_p5._1,
			_p5._2,
			_p5._3);
	} else {
		var _p6 = A3(_elm_lang$core$Color$rgbToHsl, _p5._0, _p5._1, _p5._2);
		var h = _p6._0;
		var s = _p6._1;
		var l = _p6._2;
		return A4(
			_elm_lang$core$Color$hsla,
			h + _elm_lang$core$Basics$degrees(180),
			s,
			l,
			_p5._3);
	}
};
var _elm_lang$core$Color$grayscale = function (p) {
	return A4(_elm_lang$core$Color$HSLA, 0, 0, 1 - p, 1);
};
var _elm_lang$core$Color$greyscale = function (p) {
	return A4(_elm_lang$core$Color$HSLA, 0, 0, 1 - p, 1);
};
var _elm_lang$core$Color$RGBA = F4(
	function (a, b, c, d) {
		return {ctor: 'RGBA', _0: a, _1: b, _2: c, _3: d};
	});
var _elm_lang$core$Color$rgba = _elm_lang$core$Color$RGBA;
var _elm_lang$core$Color$rgb = F3(
	function (r, g, b) {
		return A4(_elm_lang$core$Color$RGBA, r, g, b, 1);
	});
var _elm_lang$core$Color$lightRed = A4(_elm_lang$core$Color$RGBA, 239, 41, 41, 1);
var _elm_lang$core$Color$red = A4(_elm_lang$core$Color$RGBA, 204, 0, 0, 1);
var _elm_lang$core$Color$darkRed = A4(_elm_lang$core$Color$RGBA, 164, 0, 0, 1);
var _elm_lang$core$Color$lightOrange = A4(_elm_lang$core$Color$RGBA, 252, 175, 62, 1);
var _elm_lang$core$Color$orange = A4(_elm_lang$core$Color$RGBA, 245, 121, 0, 1);
var _elm_lang$core$Color$darkOrange = A4(_elm_lang$core$Color$RGBA, 206, 92, 0, 1);
var _elm_lang$core$Color$lightYellow = A4(_elm_lang$core$Color$RGBA, 255, 233, 79, 1);
var _elm_lang$core$Color$yellow = A4(_elm_lang$core$Color$RGBA, 237, 212, 0, 1);
var _elm_lang$core$Color$darkYellow = A4(_elm_lang$core$Color$RGBA, 196, 160, 0, 1);
var _elm_lang$core$Color$lightGreen = A4(_elm_lang$core$Color$RGBA, 138, 226, 52, 1);
var _elm_lang$core$Color$green = A4(_elm_lang$core$Color$RGBA, 115, 210, 22, 1);
var _elm_lang$core$Color$darkGreen = A4(_elm_lang$core$Color$RGBA, 78, 154, 6, 1);
var _elm_lang$core$Color$lightBlue = A4(_elm_lang$core$Color$RGBA, 114, 159, 207, 1);
var _elm_lang$core$Color$blue = A4(_elm_lang$core$Color$RGBA, 52, 101, 164, 1);
var _elm_lang$core$Color$darkBlue = A4(_elm_lang$core$Color$RGBA, 32, 74, 135, 1);
var _elm_lang$core$Color$lightPurple = A4(_elm_lang$core$Color$RGBA, 173, 127, 168, 1);
var _elm_lang$core$Color$purple = A4(_elm_lang$core$Color$RGBA, 117, 80, 123, 1);
var _elm_lang$core$Color$darkPurple = A4(_elm_lang$core$Color$RGBA, 92, 53, 102, 1);
var _elm_lang$core$Color$lightBrown = A4(_elm_lang$core$Color$RGBA, 233, 185, 110, 1);
var _elm_lang$core$Color$brown = A4(_elm_lang$core$Color$RGBA, 193, 125, 17, 1);
var _elm_lang$core$Color$darkBrown = A4(_elm_lang$core$Color$RGBA, 143, 89, 2, 1);
var _elm_lang$core$Color$black = A4(_elm_lang$core$Color$RGBA, 0, 0, 0, 1);
var _elm_lang$core$Color$white = A4(_elm_lang$core$Color$RGBA, 255, 255, 255, 1);
var _elm_lang$core$Color$lightGrey = A4(_elm_lang$core$Color$RGBA, 238, 238, 236, 1);
var _elm_lang$core$Color$grey = A4(_elm_lang$core$Color$RGBA, 211, 215, 207, 1);
var _elm_lang$core$Color$darkGrey = A4(_elm_lang$core$Color$RGBA, 186, 189, 182, 1);
var _elm_lang$core$Color$lightGray = A4(_elm_lang$core$Color$RGBA, 238, 238, 236, 1);
var _elm_lang$core$Color$gray = A4(_elm_lang$core$Color$RGBA, 211, 215, 207, 1);
var _elm_lang$core$Color$darkGray = A4(_elm_lang$core$Color$RGBA, 186, 189, 182, 1);
var _elm_lang$core$Color$lightCharcoal = A4(_elm_lang$core$Color$RGBA, 136, 138, 133, 1);
var _elm_lang$core$Color$charcoal = A4(_elm_lang$core$Color$RGBA, 85, 87, 83, 1);
var _elm_lang$core$Color$darkCharcoal = A4(_elm_lang$core$Color$RGBA, 46, 52, 54, 1);
var _elm_lang$core$Color$Radial = F5(
	function (a, b, c, d, e) {
		return {ctor: 'Radial', _0: a, _1: b, _2: c, _3: d, _4: e};
	});
var _elm_lang$core$Color$radial = _elm_lang$core$Color$Radial;
var _elm_lang$core$Color$Linear = F3(
	function (a, b, c) {
		return {ctor: 'Linear', _0: a, _1: b, _2: c};
	});
var _elm_lang$core$Color$linear = _elm_lang$core$Color$Linear;

//import Result //

var _elm_lang$core$Native_Date = function() {

function fromString(str)
{
	var date = new Date(str);
	return isNaN(date.getTime())
		? _elm_lang$core$Result$Err('Unable to parse \'' + str + '\' as a date. Dates must be in the ISO 8601 format.')
		: _elm_lang$core$Result$Ok(date);
}

var dayTable = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
var monthTable =
	['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
	 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];


return {
	fromString: fromString,
	year: function(d) { return d.getFullYear(); },
	month: function(d) { return { ctor: monthTable[d.getMonth()] }; },
	day: function(d) { return d.getDate(); },
	hour: function(d) { return d.getHours(); },
	minute: function(d) { return d.getMinutes(); },
	second: function(d) { return d.getSeconds(); },
	millisecond: function(d) { return d.getMilliseconds(); },
	toTime: function(d) { return d.getTime(); },
	fromTime: function(t) { return new Date(t); },
	dayOfWeek: function(d) { return { ctor: dayTable[d.getDay()] }; }
};

}();
var _elm_lang$core$Date$millisecond = _elm_lang$core$Native_Date.millisecond;
var _elm_lang$core$Date$second = _elm_lang$core$Native_Date.second;
var _elm_lang$core$Date$minute = _elm_lang$core$Native_Date.minute;
var _elm_lang$core$Date$hour = _elm_lang$core$Native_Date.hour;
var _elm_lang$core$Date$dayOfWeek = _elm_lang$core$Native_Date.dayOfWeek;
var _elm_lang$core$Date$day = _elm_lang$core$Native_Date.day;
var _elm_lang$core$Date$month = _elm_lang$core$Native_Date.month;
var _elm_lang$core$Date$year = _elm_lang$core$Native_Date.year;
var _elm_lang$core$Date$fromTime = _elm_lang$core$Native_Date.fromTime;
var _elm_lang$core$Date$toTime = _elm_lang$core$Native_Date.toTime;
var _elm_lang$core$Date$fromString = _elm_lang$core$Native_Date.fromString;
var _elm_lang$core$Date$now = A2(_elm_lang$core$Task$map, _elm_lang$core$Date$fromTime, _elm_lang$core$Time$now);
var _elm_lang$core$Date$Date = {ctor: 'Date'};
var _elm_lang$core$Date$Sun = {ctor: 'Sun'};
var _elm_lang$core$Date$Sat = {ctor: 'Sat'};
var _elm_lang$core$Date$Fri = {ctor: 'Fri'};
var _elm_lang$core$Date$Thu = {ctor: 'Thu'};
var _elm_lang$core$Date$Wed = {ctor: 'Wed'};
var _elm_lang$core$Date$Tue = {ctor: 'Tue'};
var _elm_lang$core$Date$Mon = {ctor: 'Mon'};
var _elm_lang$core$Date$Dec = {ctor: 'Dec'};
var _elm_lang$core$Date$Nov = {ctor: 'Nov'};
var _elm_lang$core$Date$Oct = {ctor: 'Oct'};
var _elm_lang$core$Date$Sep = {ctor: 'Sep'};
var _elm_lang$core$Date$Aug = {ctor: 'Aug'};
var _elm_lang$core$Date$Jul = {ctor: 'Jul'};
var _elm_lang$core$Date$Jun = {ctor: 'Jun'};
var _elm_lang$core$Date$May = {ctor: 'May'};
var _elm_lang$core$Date$Apr = {ctor: 'Apr'};
var _elm_lang$core$Date$Mar = {ctor: 'Mar'};
var _elm_lang$core$Date$Feb = {ctor: 'Feb'};
var _elm_lang$core$Date$Jan = {ctor: 'Jan'};

//import Maybe, Native.Array, Native.List, Native.Utils, Result //

var _elm_lang$core$Native_Json = function() {


// CORE DECODERS

function succeed(msg)
{
	return {
		ctor: '<decoder>',
		tag: 'succeed',
		msg: msg
	};
}

function fail(msg)
{
	return {
		ctor: '<decoder>',
		tag: 'fail',
		msg: msg
	};
}

function decodePrimitive(tag)
{
	return {
		ctor: '<decoder>',
		tag: tag
	};
}

function decodeContainer(tag, decoder)
{
	return {
		ctor: '<decoder>',
		tag: tag,
		decoder: decoder
	};
}

function decodeNull(value)
{
	return {
		ctor: '<decoder>',
		tag: 'null',
		value: value
	};
}

function decodeField(field, decoder)
{
	return {
		ctor: '<decoder>',
		tag: 'field',
		field: field,
		decoder: decoder
	};
}

function decodeIndex(index, decoder)
{
	return {
		ctor: '<decoder>',
		tag: 'index',
		index: index,
		decoder: decoder
	};
}

function decodeKeyValuePairs(decoder)
{
	return {
		ctor: '<decoder>',
		tag: 'key-value',
		decoder: decoder
	};
}

function mapMany(f, decoders)
{
	return {
		ctor: '<decoder>',
		tag: 'map-many',
		func: f,
		decoders: decoders
	};
}

function andThen(callback, decoder)
{
	return {
		ctor: '<decoder>',
		tag: 'andThen',
		decoder: decoder,
		callback: callback
	};
}

function oneOf(decoders)
{
	return {
		ctor: '<decoder>',
		tag: 'oneOf',
		decoders: decoders
	};
}


// DECODING OBJECTS

function map1(f, d1)
{
	return mapMany(f, [d1]);
}

function map2(f, d1, d2)
{
	return mapMany(f, [d1, d2]);
}

function map3(f, d1, d2, d3)
{
	return mapMany(f, [d1, d2, d3]);
}

function map4(f, d1, d2, d3, d4)
{
	return mapMany(f, [d1, d2, d3, d4]);
}

function map5(f, d1, d2, d3, d4, d5)
{
	return mapMany(f, [d1, d2, d3, d4, d5]);
}

function map6(f, d1, d2, d3, d4, d5, d6)
{
	return mapMany(f, [d1, d2, d3, d4, d5, d6]);
}

function map7(f, d1, d2, d3, d4, d5, d6, d7)
{
	return mapMany(f, [d1, d2, d3, d4, d5, d6, d7]);
}

function map8(f, d1, d2, d3, d4, d5, d6, d7, d8)
{
	return mapMany(f, [d1, d2, d3, d4, d5, d6, d7, d8]);
}


// DECODE HELPERS

function ok(value)
{
	return { tag: 'ok', value: value };
}

function badPrimitive(type, value)
{
	return { tag: 'primitive', type: type, value: value };
}

function badIndex(index, nestedProblems)
{
	return { tag: 'index', index: index, rest: nestedProblems };
}

function badField(field, nestedProblems)
{
	return { tag: 'field', field: field, rest: nestedProblems };
}

function badIndex(index, nestedProblems)
{
	return { tag: 'index', index: index, rest: nestedProblems };
}

function badOneOf(problems)
{
	return { tag: 'oneOf', problems: problems };
}

function bad(msg)
{
	return { tag: 'fail', msg: msg };
}

function badToString(problem)
{
	var context = '_';
	while (problem)
	{
		switch (problem.tag)
		{
			case 'primitive':
				return 'Expecting ' + problem.type
					+ (context === '_' ? '' : ' at ' + context)
					+ ' but instead got: ' + jsToString(problem.value);

			case 'index':
				context += '[' + problem.index + ']';
				problem = problem.rest;
				break;

			case 'field':
				context += '.' + problem.field;
				problem = problem.rest;
				break;

			case 'index':
				context += '[' + problem.index + ']';
				problem = problem.rest;
				break;

			case 'oneOf':
				var problems = problem.problems;
				for (var i = 0; i < problems.length; i++)
				{
					problems[i] = badToString(problems[i]);
				}
				return 'I ran into the following problems'
					+ (context === '_' ? '' : ' at ' + context)
					+ ':\n\n' + problems.join('\n');

			case 'fail':
				return 'I ran into a `fail` decoder'
					+ (context === '_' ? '' : ' at ' + context)
					+ ': ' + problem.msg;
		}
	}
}

function jsToString(value)
{
	return value === undefined
		? 'undefined'
		: JSON.stringify(value);
}


// DECODE

function runOnString(decoder, string)
{
	var json;
	try
	{
		json = JSON.parse(string);
	}
	catch (e)
	{
		return _elm_lang$core$Result$Err('Given an invalid JSON: ' + e.message);
	}
	return run(decoder, json);
}

function run(decoder, value)
{
	var result = runHelp(decoder, value);
	return (result.tag === 'ok')
		? _elm_lang$core$Result$Ok(result.value)
		: _elm_lang$core$Result$Err(badToString(result));
}

function runHelp(decoder, value)
{
	switch (decoder.tag)
	{
		case 'bool':
			return (typeof value === 'boolean')
				? ok(value)
				: badPrimitive('a Bool', value);

		case 'int':
			if (typeof value !== 'number') {
				return badPrimitive('an Int', value);
			}

			if (-2147483647 < value && value < 2147483647 && (value | 0) === value) {
				return ok(value);
			}

			if (isFinite(value) && !(value % 1)) {
				return ok(value);
			}

			return badPrimitive('an Int', value);

		case 'float':
			return (typeof value === 'number')
				? ok(value)
				: badPrimitive('a Float', value);

		case 'string':
			return (typeof value === 'string')
				? ok(value)
				: (value instanceof String)
					? ok(value + '')
					: badPrimitive('a String', value);

		case 'null':
			return (value === null)
				? ok(decoder.value)
				: badPrimitive('null', value);

		case 'value':
			return ok(value);

		case 'list':
			if (!(value instanceof Array))
			{
				return badPrimitive('a List', value);
			}

			var list = _elm_lang$core$Native_List.Nil;
			for (var i = value.length; i--; )
			{
				var result = runHelp(decoder.decoder, value[i]);
				if (result.tag !== 'ok')
				{
					return badIndex(i, result)
				}
				list = _elm_lang$core$Native_List.Cons(result.value, list);
			}
			return ok(list);

		case 'array':
			if (!(value instanceof Array))
			{
				return badPrimitive('an Array', value);
			}

			var len = value.length;
			var array = new Array(len);
			for (var i = len; i--; )
			{
				var result = runHelp(decoder.decoder, value[i]);
				if (result.tag !== 'ok')
				{
					return badIndex(i, result);
				}
				array[i] = result.value;
			}
			return ok(_elm_lang$core$Native_Array.fromJSArray(array));

		case 'maybe':
			var result = runHelp(decoder.decoder, value);
			return (result.tag === 'ok')
				? ok(_elm_lang$core$Maybe$Just(result.value))
				: ok(_elm_lang$core$Maybe$Nothing);

		case 'field':
			var field = decoder.field;
			if (typeof value !== 'object' || value === null || !(field in value))
			{
				return badPrimitive('an object with a field named `' + field + '`', value);
			}

			var result = runHelp(decoder.decoder, value[field]);
			return (result.tag === 'ok') ? result : badField(field, result);

		case 'index':
			var index = decoder.index;
			if (!(value instanceof Array))
			{
				return badPrimitive('an array', value);
			}
			if (index >= value.length)
			{
				return badPrimitive('a longer array. Need index ' + index + ' but there are only ' + value.length + ' entries', value);
			}

			var result = runHelp(decoder.decoder, value[index]);
			return (result.tag === 'ok') ? result : badIndex(index, result);

		case 'key-value':
			if (typeof value !== 'object' || value === null || value instanceof Array)
			{
				return badPrimitive('an object', value);
			}

			var keyValuePairs = _elm_lang$core$Native_List.Nil;
			for (var key in value)
			{
				var result = runHelp(decoder.decoder, value[key]);
				if (result.tag !== 'ok')
				{
					return badField(key, result);
				}
				var pair = _elm_lang$core$Native_Utils.Tuple2(key, result.value);
				keyValuePairs = _elm_lang$core$Native_List.Cons(pair, keyValuePairs);
			}
			return ok(keyValuePairs);

		case 'map-many':
			var answer = decoder.func;
			var decoders = decoder.decoders;
			for (var i = 0; i < decoders.length; i++)
			{
				var result = runHelp(decoders[i], value);
				if (result.tag !== 'ok')
				{
					return result;
				}
				answer = answer(result.value);
			}
			return ok(answer);

		case 'andThen':
			var result = runHelp(decoder.decoder, value);
			return (result.tag !== 'ok')
				? result
				: runHelp(decoder.callback(result.value), value);

		case 'oneOf':
			var errors = [];
			var temp = decoder.decoders;
			while (temp.ctor !== '[]')
			{
				var result = runHelp(temp._0, value);

				if (result.tag === 'ok')
				{
					return result;
				}

				errors.push(result);

				temp = temp._1;
			}
			return badOneOf(errors);

		case 'fail':
			return bad(decoder.msg);

		case 'succeed':
			return ok(decoder.msg);
	}
}


// EQUALITY

function equality(a, b)
{
	if (a === b)
	{
		return true;
	}

	if (a.tag !== b.tag)
	{
		return false;
	}

	switch (a.tag)
	{
		case 'succeed':
		case 'fail':
			return a.msg === b.msg;

		case 'bool':
		case 'int':
		case 'float':
		case 'string':
		case 'value':
			return true;

		case 'null':
			return a.value === b.value;

		case 'list':
		case 'array':
		case 'maybe':
		case 'key-value':
			return equality(a.decoder, b.decoder);

		case 'field':
			return a.field === b.field && equality(a.decoder, b.decoder);

		case 'index':
			return a.index === b.index && equality(a.decoder, b.decoder);

		case 'map-many':
			if (a.func !== b.func)
			{
				return false;
			}
			return listEquality(a.decoders, b.decoders);

		case 'andThen':
			return a.callback === b.callback && equality(a.decoder, b.decoder);

		case 'oneOf':
			return listEquality(a.decoders, b.decoders);
	}
}

function listEquality(aDecoders, bDecoders)
{
	var len = aDecoders.length;
	if (len !== bDecoders.length)
	{
		return false;
	}
	for (var i = 0; i < len; i++)
	{
		if (!equality(aDecoders[i], bDecoders[i]))
		{
			return false;
		}
	}
	return true;
}


// ENCODE

function encode(indentLevel, value)
{
	return JSON.stringify(value, null, indentLevel);
}

function identity(value)
{
	return value;
}

function encodeObject(keyValuePairs)
{
	var obj = {};
	while (keyValuePairs.ctor !== '[]')
	{
		var pair = keyValuePairs._0;
		obj[pair._0] = pair._1;
		keyValuePairs = keyValuePairs._1;
	}
	return obj;
}

return {
	encode: F2(encode),
	runOnString: F2(runOnString),
	run: F2(run),

	decodeNull: decodeNull,
	decodePrimitive: decodePrimitive,
	decodeContainer: F2(decodeContainer),

	decodeField: F2(decodeField),
	decodeIndex: F2(decodeIndex),

	map1: F2(map1),
	map2: F3(map2),
	map3: F4(map3),
	map4: F5(map4),
	map5: F6(map5),
	map6: F7(map6),
	map7: F8(map7),
	map8: F9(map8),
	decodeKeyValuePairs: decodeKeyValuePairs,

	andThen: F2(andThen),
	fail: fail,
	succeed: succeed,
	oneOf: oneOf,

	identity: identity,
	encodeNull: null,
	encodeArray: _elm_lang$core$Native_Array.toJSArray,
	encodeList: _elm_lang$core$Native_List.toArray,
	encodeObject: encodeObject,

	equality: equality
};

}();

var _elm_lang$core$Json_Encode$list = _elm_lang$core$Native_Json.encodeList;
var _elm_lang$core$Json_Encode$array = _elm_lang$core$Native_Json.encodeArray;
var _elm_lang$core$Json_Encode$object = _elm_lang$core$Native_Json.encodeObject;
var _elm_lang$core$Json_Encode$null = _elm_lang$core$Native_Json.encodeNull;
var _elm_lang$core$Json_Encode$bool = _elm_lang$core$Native_Json.identity;
var _elm_lang$core$Json_Encode$float = _elm_lang$core$Native_Json.identity;
var _elm_lang$core$Json_Encode$int = _elm_lang$core$Native_Json.identity;
var _elm_lang$core$Json_Encode$string = _elm_lang$core$Native_Json.identity;
var _elm_lang$core$Json_Encode$encode = _elm_lang$core$Native_Json.encode;
var _elm_lang$core$Json_Encode$Value = {ctor: 'Value'};

var _elm_lang$core$Json_Decode$null = _elm_lang$core$Native_Json.decodeNull;
var _elm_lang$core$Json_Decode$value = _elm_lang$core$Native_Json.decodePrimitive('value');
var _elm_lang$core$Json_Decode$andThen = _elm_lang$core$Native_Json.andThen;
var _elm_lang$core$Json_Decode$fail = _elm_lang$core$Native_Json.fail;
var _elm_lang$core$Json_Decode$succeed = _elm_lang$core$Native_Json.succeed;
var _elm_lang$core$Json_Decode$lazy = function (thunk) {
	return A2(
		_elm_lang$core$Json_Decode$andThen,
		thunk,
		_elm_lang$core$Json_Decode$succeed(
			{ctor: '_Tuple0'}));
};
var _elm_lang$core$Json_Decode$decodeValue = _elm_lang$core$Native_Json.run;
var _elm_lang$core$Json_Decode$decodeString = _elm_lang$core$Native_Json.runOnString;
var _elm_lang$core$Json_Decode$map8 = _elm_lang$core$Native_Json.map8;
var _elm_lang$core$Json_Decode$map7 = _elm_lang$core$Native_Json.map7;
var _elm_lang$core$Json_Decode$map6 = _elm_lang$core$Native_Json.map6;
var _elm_lang$core$Json_Decode$map5 = _elm_lang$core$Native_Json.map5;
var _elm_lang$core$Json_Decode$map4 = _elm_lang$core$Native_Json.map4;
var _elm_lang$core$Json_Decode$map3 = _elm_lang$core$Native_Json.map3;
var _elm_lang$core$Json_Decode$map2 = _elm_lang$core$Native_Json.map2;
var _elm_lang$core$Json_Decode$map = _elm_lang$core$Native_Json.map1;
var _elm_lang$core$Json_Decode$oneOf = _elm_lang$core$Native_Json.oneOf;
var _elm_lang$core$Json_Decode$maybe = function (decoder) {
	return A2(_elm_lang$core$Native_Json.decodeContainer, 'maybe', decoder);
};
var _elm_lang$core$Json_Decode$index = _elm_lang$core$Native_Json.decodeIndex;
var _elm_lang$core$Json_Decode$field = _elm_lang$core$Native_Json.decodeField;
var _elm_lang$core$Json_Decode$at = F2(
	function (fields, decoder) {
		return A3(_elm_lang$core$List$foldr, _elm_lang$core$Json_Decode$field, decoder, fields);
	});
var _elm_lang$core$Json_Decode$keyValuePairs = _elm_lang$core$Native_Json.decodeKeyValuePairs;
var _elm_lang$core$Json_Decode$dict = function (decoder) {
	return A2(
		_elm_lang$core$Json_Decode$map,
		_elm_lang$core$Dict$fromList,
		_elm_lang$core$Json_Decode$keyValuePairs(decoder));
};
var _elm_lang$core$Json_Decode$array = function (decoder) {
	return A2(_elm_lang$core$Native_Json.decodeContainer, 'array', decoder);
};
var _elm_lang$core$Json_Decode$list = function (decoder) {
	return A2(_elm_lang$core$Native_Json.decodeContainer, 'list', decoder);
};
var _elm_lang$core$Json_Decode$nullable = function (decoder) {
	return _elm_lang$core$Json_Decode$oneOf(
		{
			ctor: '::',
			_0: _elm_lang$core$Json_Decode$null(_elm_lang$core$Maybe$Nothing),
			_1: {
				ctor: '::',
				_0: A2(_elm_lang$core$Json_Decode$map, _elm_lang$core$Maybe$Just, decoder),
				_1: {ctor: '[]'}
			}
		});
};
var _elm_lang$core$Json_Decode$float = _elm_lang$core$Native_Json.decodePrimitive('float');
var _elm_lang$core$Json_Decode$int = _elm_lang$core$Native_Json.decodePrimitive('int');
var _elm_lang$core$Json_Decode$bool = _elm_lang$core$Native_Json.decodePrimitive('bool');
var _elm_lang$core$Json_Decode$string = _elm_lang$core$Native_Json.decodePrimitive('string');
var _elm_lang$core$Json_Decode$Decoder = {ctor: 'Decoder'};

var _elm_lang$dom$Native_Dom = function() {

var fakeNode = {
	addEventListener: function() {},
	removeEventListener: function() {}
};

var onDocument = on(typeof document !== 'undefined' ? document : fakeNode);
var onWindow = on(typeof window !== 'undefined' ? window : fakeNode);

function on(node)
{
	return function(eventName, decoder, toTask)
	{
		return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {

			function performTask(event)
			{
				var result = A2(_elm_lang$core$Json_Decode$decodeValue, decoder, event);
				if (result.ctor === 'Ok')
				{
					_elm_lang$core$Native_Scheduler.rawSpawn(toTask(result._0));
				}
			}

			node.addEventListener(eventName, performTask);

			return function()
			{
				node.removeEventListener(eventName, performTask);
			};
		});
	};
}

var rAF = typeof requestAnimationFrame !== 'undefined'
	? requestAnimationFrame
	: function(callback) { callback(); };

function withNode(id, doStuff)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		rAF(function()
		{
			var node = document.getElementById(id);
			if (node === null)
			{
				callback(_elm_lang$core$Native_Scheduler.fail({ ctor: 'NotFound', _0: id }));
				return;
			}
			callback(_elm_lang$core$Native_Scheduler.succeed(doStuff(node)));
		});
	});
}


// FOCUS

function focus(id)
{
	return withNode(id, function(node) {
		node.focus();
		return _elm_lang$core$Native_Utils.Tuple0;
	});
}

function blur(id)
{
	return withNode(id, function(node) {
		node.blur();
		return _elm_lang$core$Native_Utils.Tuple0;
	});
}


// SCROLLING

function getScrollTop(id)
{
	return withNode(id, function(node) {
		return node.scrollTop;
	});
}

function setScrollTop(id, desiredScrollTop)
{
	return withNode(id, function(node) {
		node.scrollTop = desiredScrollTop;
		return _elm_lang$core$Native_Utils.Tuple0;
	});
}

function toBottom(id)
{
	return withNode(id, function(node) {
		node.scrollTop = node.scrollHeight;
		return _elm_lang$core$Native_Utils.Tuple0;
	});
}

function getScrollLeft(id)
{
	return withNode(id, function(node) {
		return node.scrollLeft;
	});
}

function setScrollLeft(id, desiredScrollLeft)
{
	return withNode(id, function(node) {
		node.scrollLeft = desiredScrollLeft;
		return _elm_lang$core$Native_Utils.Tuple0;
	});
}

function toRight(id)
{
	return withNode(id, function(node) {
		node.scrollLeft = node.scrollWidth;
		return _elm_lang$core$Native_Utils.Tuple0;
	});
}


// SIZE

function width(options, id)
{
	return withNode(id, function(node) {
		switch (options.ctor)
		{
			case 'Content':
				return node.scrollWidth;
			case 'VisibleContent':
				return node.clientWidth;
			case 'VisibleContentWithBorders':
				return node.offsetWidth;
			case 'VisibleContentWithBordersAndMargins':
				var rect = node.getBoundingClientRect();
				return rect.right - rect.left;
		}
	});
}

function height(options, id)
{
	return withNode(id, function(node) {
		switch (options.ctor)
		{
			case 'Content':
				return node.scrollHeight;
			case 'VisibleContent':
				return node.clientHeight;
			case 'VisibleContentWithBorders':
				return node.offsetHeight;
			case 'VisibleContentWithBordersAndMargins':
				var rect = node.getBoundingClientRect();
				return rect.bottom - rect.top;
		}
	});
}

return {
	onDocument: F3(onDocument),
	onWindow: F3(onWindow),

	focus: focus,
	blur: blur,

	getScrollTop: getScrollTop,
	setScrollTop: F2(setScrollTop),
	getScrollLeft: getScrollLeft,
	setScrollLeft: F2(setScrollLeft),
	toBottom: toBottom,
	toRight: toRight,

	height: F2(height),
	width: F2(width)
};

}();

var _elm_lang$dom$Dom_LowLevel$onWindow = _elm_lang$dom$Native_Dom.onWindow;
var _elm_lang$dom$Dom_LowLevel$onDocument = _elm_lang$dom$Native_Dom.onDocument;

var _elm_lang$virtual_dom$VirtualDom_Debug$wrap;
var _elm_lang$virtual_dom$VirtualDom_Debug$wrapWithFlags;

var _elm_lang$virtual_dom$Native_VirtualDom = function() {

var STYLE_KEY = 'STYLE';
var EVENT_KEY = 'EVENT';
var ATTR_KEY = 'ATTR';
var ATTR_NS_KEY = 'ATTR_NS';

var localDoc = typeof document !== 'undefined' ? document : {};


////////////  VIRTUAL DOM NODES  ////////////


function text(string)
{
	return {
		type: 'text',
		text: string
	};
}


function node(tag)
{
	return F2(function(factList, kidList) {
		return nodeHelp(tag, factList, kidList);
	});
}


function nodeHelp(tag, factList, kidList)
{
	var organized = organizeFacts(factList);
	var namespace = organized.namespace;
	var facts = organized.facts;

	var children = [];
	var descendantsCount = 0;
	while (kidList.ctor !== '[]')
	{
		var kid = kidList._0;
		descendantsCount += (kid.descendantsCount || 0);
		children.push(kid);
		kidList = kidList._1;
	}
	descendantsCount += children.length;

	return {
		type: 'node',
		tag: tag,
		facts: facts,
		children: children,
		namespace: namespace,
		descendantsCount: descendantsCount
	};
}


function keyedNode(tag, factList, kidList)
{
	var organized = organizeFacts(factList);
	var namespace = organized.namespace;
	var facts = organized.facts;

	var children = [];
	var descendantsCount = 0;
	while (kidList.ctor !== '[]')
	{
		var kid = kidList._0;
		descendantsCount += (kid._1.descendantsCount || 0);
		children.push(kid);
		kidList = kidList._1;
	}
	descendantsCount += children.length;

	return {
		type: 'keyed-node',
		tag: tag,
		facts: facts,
		children: children,
		namespace: namespace,
		descendantsCount: descendantsCount
	};
}


function custom(factList, model, impl)
{
	var facts = organizeFacts(factList).facts;

	return {
		type: 'custom',
		facts: facts,
		model: model,
		impl: impl
	};
}


function map(tagger, node)
{
	return {
		type: 'tagger',
		tagger: tagger,
		node: node,
		descendantsCount: 1 + (node.descendantsCount || 0)
	};
}


function thunk(func, args, thunk)
{
	return {
		type: 'thunk',
		func: func,
		args: args,
		thunk: thunk,
		node: undefined
	};
}

function lazy(fn, a)
{
	return thunk(fn, [a], function() {
		return fn(a);
	});
}

function lazy2(fn, a, b)
{
	return thunk(fn, [a,b], function() {
		return A2(fn, a, b);
	});
}

function lazy3(fn, a, b, c)
{
	return thunk(fn, [a,b,c], function() {
		return A3(fn, a, b, c);
	});
}



// FACTS


function organizeFacts(factList)
{
	var namespace, facts = {};

	while (factList.ctor !== '[]')
	{
		var entry = factList._0;
		var key = entry.key;

		if (key === ATTR_KEY || key === ATTR_NS_KEY || key === EVENT_KEY)
		{
			var subFacts = facts[key] || {};
			subFacts[entry.realKey] = entry.value;
			facts[key] = subFacts;
		}
		else if (key === STYLE_KEY)
		{
			var styles = facts[key] || {};
			var styleList = entry.value;
			while (styleList.ctor !== '[]')
			{
				var style = styleList._0;
				styles[style._0] = style._1;
				styleList = styleList._1;
			}
			facts[key] = styles;
		}
		else if (key === 'namespace')
		{
			namespace = entry.value;
		}
		else if (key === 'className')
		{
			var classes = facts[key];
			facts[key] = typeof classes === 'undefined'
				? entry.value
				: classes + ' ' + entry.value;
		}
 		else
		{
			facts[key] = entry.value;
		}
		factList = factList._1;
	}

	return {
		facts: facts,
		namespace: namespace
	};
}



////////////  PROPERTIES AND ATTRIBUTES  ////////////


function style(value)
{
	return {
		key: STYLE_KEY,
		value: value
	};
}


function property(key, value)
{
	return {
		key: key,
		value: value
	};
}


function attribute(key, value)
{
	return {
		key: ATTR_KEY,
		realKey: key,
		value: value
	};
}


function attributeNS(namespace, key, value)
{
	return {
		key: ATTR_NS_KEY,
		realKey: key,
		value: {
			value: value,
			namespace: namespace
		}
	};
}


function on(name, options, decoder)
{
	return {
		key: EVENT_KEY,
		realKey: name,
		value: {
			options: options,
			decoder: decoder
		}
	};
}


function equalEvents(a, b)
{
	if (!a.options === b.options)
	{
		if (a.stopPropagation !== b.stopPropagation || a.preventDefault !== b.preventDefault)
		{
			return false;
		}
	}
	return _elm_lang$core$Native_Json.equality(a.decoder, b.decoder);
}


function mapProperty(func, property)
{
	if (property.key !== EVENT_KEY)
	{
		return property;
	}
	return on(
		property.realKey,
		property.value.options,
		A2(_elm_lang$core$Json_Decode$map, func, property.value.decoder)
	);
}


////////////  RENDER  ////////////


function render(vNode, eventNode)
{
	switch (vNode.type)
	{
		case 'thunk':
			if (!vNode.node)
			{
				vNode.node = vNode.thunk();
			}
			return render(vNode.node, eventNode);

		case 'tagger':
			var subNode = vNode.node;
			var tagger = vNode.tagger;

			while (subNode.type === 'tagger')
			{
				typeof tagger !== 'object'
					? tagger = [tagger, subNode.tagger]
					: tagger.push(subNode.tagger);

				subNode = subNode.node;
			}

			var subEventRoot = { tagger: tagger, parent: eventNode };
			var domNode = render(subNode, subEventRoot);
			domNode.elm_event_node_ref = subEventRoot;
			return domNode;

		case 'text':
			return localDoc.createTextNode(vNode.text);

		case 'node':
			var domNode = vNode.namespace
				? localDoc.createElementNS(vNode.namespace, vNode.tag)
				: localDoc.createElement(vNode.tag);

			applyFacts(domNode, eventNode, vNode.facts);

			var children = vNode.children;

			for (var i = 0; i < children.length; i++)
			{
				domNode.appendChild(render(children[i], eventNode));
			}

			return domNode;

		case 'keyed-node':
			var domNode = vNode.namespace
				? localDoc.createElementNS(vNode.namespace, vNode.tag)
				: localDoc.createElement(vNode.tag);

			applyFacts(domNode, eventNode, vNode.facts);

			var children = vNode.children;

			for (var i = 0; i < children.length; i++)
			{
				domNode.appendChild(render(children[i]._1, eventNode));
			}

			return domNode;

		case 'custom':
			var domNode = vNode.impl.render(vNode.model);
			applyFacts(domNode, eventNode, vNode.facts);
			return domNode;
	}
}



////////////  APPLY FACTS  ////////////


function applyFacts(domNode, eventNode, facts)
{
	for (var key in facts)
	{
		var value = facts[key];

		switch (key)
		{
			case STYLE_KEY:
				applyStyles(domNode, value);
				break;

			case EVENT_KEY:
				applyEvents(domNode, eventNode, value);
				break;

			case ATTR_KEY:
				applyAttrs(domNode, value);
				break;

			case ATTR_NS_KEY:
				applyAttrsNS(domNode, value);
				break;

			case 'value':
				if (domNode[key] !== value)
				{
					domNode[key] = value;
				}
				break;

			default:
				domNode[key] = value;
				break;
		}
	}
}

function applyStyles(domNode, styles)
{
	var domNodeStyle = domNode.style;

	for (var key in styles)
	{
		domNodeStyle[key] = styles[key];
	}
}

function applyEvents(domNode, eventNode, events)
{
	var allHandlers = domNode.elm_handlers || {};

	for (var key in events)
	{
		var handler = allHandlers[key];
		var value = events[key];

		if (typeof value === 'undefined')
		{
			domNode.removeEventListener(key, handler);
			allHandlers[key] = undefined;
		}
		else if (typeof handler === 'undefined')
		{
			var handler = makeEventHandler(eventNode, value);
			domNode.addEventListener(key, handler);
			allHandlers[key] = handler;
		}
		else
		{
			handler.info = value;
		}
	}

	domNode.elm_handlers = allHandlers;
}

function makeEventHandler(eventNode, info)
{
	function eventHandler(event)
	{
		var info = eventHandler.info;

		var value = A2(_elm_lang$core$Native_Json.run, info.decoder, event);

		if (value.ctor === 'Ok')
		{
			var options = info.options;
			if (options.stopPropagation)
			{
				event.stopPropagation();
			}
			if (options.preventDefault)
			{
				event.preventDefault();
			}

			var message = value._0;

			var currentEventNode = eventNode;
			while (currentEventNode)
			{
				var tagger = currentEventNode.tagger;
				if (typeof tagger === 'function')
				{
					message = tagger(message);
				}
				else
				{
					for (var i = tagger.length; i--; )
					{
						message = tagger[i](message);
					}
				}
				currentEventNode = currentEventNode.parent;
			}
		}
	};

	eventHandler.info = info;

	return eventHandler;
}

function applyAttrs(domNode, attrs)
{
	for (var key in attrs)
	{
		var value = attrs[key];
		if (typeof value === 'undefined')
		{
			domNode.removeAttribute(key);
		}
		else
		{
			domNode.setAttribute(key, value);
		}
	}
}

function applyAttrsNS(domNode, nsAttrs)
{
	for (var key in nsAttrs)
	{
		var pair = nsAttrs[key];
		var namespace = pair.namespace;
		var value = pair.value;

		if (typeof value === 'undefined')
		{
			domNode.removeAttributeNS(namespace, key);
		}
		else
		{
			domNode.setAttributeNS(namespace, key, value);
		}
	}
}



////////////  DIFF  ////////////


function diff(a, b)
{
	var patches = [];
	diffHelp(a, b, patches, 0);
	return patches;
}


function makePatch(type, index, data)
{
	return {
		index: index,
		type: type,
		data: data,
		domNode: undefined,
		eventNode: undefined
	};
}


function diffHelp(a, b, patches, index)
{
	if (a === b)
	{
		return;
	}

	var aType = a.type;
	var bType = b.type;

	// Bail if you run into different types of nodes. Implies that the
	// structure has changed significantly and it's not worth a diff.
	if (aType !== bType)
	{
		patches.push(makePatch('p-redraw', index, b));
		return;
	}

	// Now we know that both nodes are the same type.
	switch (bType)
	{
		case 'thunk':
			var aArgs = a.args;
			var bArgs = b.args;
			var i = aArgs.length;
			var same = a.func === b.func && i === bArgs.length;
			while (same && i--)
			{
				same = aArgs[i] === bArgs[i];
			}
			if (same)
			{
				b.node = a.node;
				return;
			}
			b.node = b.thunk();
			var subPatches = [];
			diffHelp(a.node, b.node, subPatches, 0);
			if (subPatches.length > 0)
			{
				patches.push(makePatch('p-thunk', index, subPatches));
			}
			return;

		case 'tagger':
			// gather nested taggers
			var aTaggers = a.tagger;
			var bTaggers = b.tagger;
			var nesting = false;

			var aSubNode = a.node;
			while (aSubNode.type === 'tagger')
			{
				nesting = true;

				typeof aTaggers !== 'object'
					? aTaggers = [aTaggers, aSubNode.tagger]
					: aTaggers.push(aSubNode.tagger);

				aSubNode = aSubNode.node;
			}

			var bSubNode = b.node;
			while (bSubNode.type === 'tagger')
			{
				nesting = true;

				typeof bTaggers !== 'object'
					? bTaggers = [bTaggers, bSubNode.tagger]
					: bTaggers.push(bSubNode.tagger);

				bSubNode = bSubNode.node;
			}

			// Just bail if different numbers of taggers. This implies the
			// structure of the virtual DOM has changed.
			if (nesting && aTaggers.length !== bTaggers.length)
			{
				patches.push(makePatch('p-redraw', index, b));
				return;
			}

			// check if taggers are "the same"
			if (nesting ? !pairwiseRefEqual(aTaggers, bTaggers) : aTaggers !== bTaggers)
			{
				patches.push(makePatch('p-tagger', index, bTaggers));
			}

			// diff everything below the taggers
			diffHelp(aSubNode, bSubNode, patches, index + 1);
			return;

		case 'text':
			if (a.text !== b.text)
			{
				patches.push(makePatch('p-text', index, b.text));
				return;
			}

			return;

		case 'node':
			// Bail if obvious indicators have changed. Implies more serious
			// structural changes such that it's not worth it to diff.
			if (a.tag !== b.tag || a.namespace !== b.namespace)
			{
				patches.push(makePatch('p-redraw', index, b));
				return;
			}

			var factsDiff = diffFacts(a.facts, b.facts);

			if (typeof factsDiff !== 'undefined')
			{
				patches.push(makePatch('p-facts', index, factsDiff));
			}

			diffChildren(a, b, patches, index);
			return;

		case 'keyed-node':
			// Bail if obvious indicators have changed. Implies more serious
			// structural changes such that it's not worth it to diff.
			if (a.tag !== b.tag || a.namespace !== b.namespace)
			{
				patches.push(makePatch('p-redraw', index, b));
				return;
			}

			var factsDiff = diffFacts(a.facts, b.facts);

			if (typeof factsDiff !== 'undefined')
			{
				patches.push(makePatch('p-facts', index, factsDiff));
			}

			diffKeyedChildren(a, b, patches, index);
			return;

		case 'custom':
			if (a.impl !== b.impl)
			{
				patches.push(makePatch('p-redraw', index, b));
				return;
			}

			var factsDiff = diffFacts(a.facts, b.facts);
			if (typeof factsDiff !== 'undefined')
			{
				patches.push(makePatch('p-facts', index, factsDiff));
			}

			var patch = b.impl.diff(a,b);
			if (patch)
			{
				patches.push(makePatch('p-custom', index, patch));
				return;
			}

			return;
	}
}


// assumes the incoming arrays are the same length
function pairwiseRefEqual(as, bs)
{
	for (var i = 0; i < as.length; i++)
	{
		if (as[i] !== bs[i])
		{
			return false;
		}
	}

	return true;
}


// TODO Instead of creating a new diff object, it's possible to just test if
// there *is* a diff. During the actual patch, do the diff again and make the
// modifications directly. This way, there's no new allocations. Worth it?
function diffFacts(a, b, category)
{
	var diff;

	// look for changes and removals
	for (var aKey in a)
	{
		if (aKey === STYLE_KEY || aKey === EVENT_KEY || aKey === ATTR_KEY || aKey === ATTR_NS_KEY)
		{
			var subDiff = diffFacts(a[aKey], b[aKey] || {}, aKey);
			if (subDiff)
			{
				diff = diff || {};
				diff[aKey] = subDiff;
			}
			continue;
		}

		// remove if not in the new facts
		if (!(aKey in b))
		{
			diff = diff || {};
			diff[aKey] =
				(typeof category === 'undefined')
					? (typeof a[aKey] === 'string' ? '' : null)
					:
				(category === STYLE_KEY)
					? ''
					:
				(category === EVENT_KEY || category === ATTR_KEY)
					? undefined
					:
				{ namespace: a[aKey].namespace, value: undefined };

			continue;
		}

		var aValue = a[aKey];
		var bValue = b[aKey];

		// reference equal, so don't worry about it
		if (aValue === bValue && aKey !== 'value'
			|| category === EVENT_KEY && equalEvents(aValue, bValue))
		{
			continue;
		}

		diff = diff || {};
		diff[aKey] = bValue;
	}

	// add new stuff
	for (var bKey in b)
	{
		if (!(bKey in a))
		{
			diff = diff || {};
			diff[bKey] = b[bKey];
		}
	}

	return diff;
}


function diffChildren(aParent, bParent, patches, rootIndex)
{
	var aChildren = aParent.children;
	var bChildren = bParent.children;

	var aLen = aChildren.length;
	var bLen = bChildren.length;

	// FIGURE OUT IF THERE ARE INSERTS OR REMOVALS

	if (aLen > bLen)
	{
		patches.push(makePatch('p-remove-last', rootIndex, aLen - bLen));
	}
	else if (aLen < bLen)
	{
		patches.push(makePatch('p-append', rootIndex, bChildren.slice(aLen)));
	}

	// PAIRWISE DIFF EVERYTHING ELSE

	var index = rootIndex;
	var minLen = aLen < bLen ? aLen : bLen;
	for (var i = 0; i < minLen; i++)
	{
		index++;
		var aChild = aChildren[i];
		diffHelp(aChild, bChildren[i], patches, index);
		index += aChild.descendantsCount || 0;
	}
}



////////////  KEYED DIFF  ////////////


function diffKeyedChildren(aParent, bParent, patches, rootIndex)
{
	var localPatches = [];

	var changes = {}; // Dict String Entry
	var inserts = []; // Array { index : Int, entry : Entry }
	// type Entry = { tag : String, vnode : VNode, index : Int, data : _ }

	var aChildren = aParent.children;
	var bChildren = bParent.children;
	var aLen = aChildren.length;
	var bLen = bChildren.length;
	var aIndex = 0;
	var bIndex = 0;

	var index = rootIndex;

	while (aIndex < aLen && bIndex < bLen)
	{
		var a = aChildren[aIndex];
		var b = bChildren[bIndex];

		var aKey = a._0;
		var bKey = b._0;
		var aNode = a._1;
		var bNode = b._1;

		// check if keys match

		if (aKey === bKey)
		{
			index++;
			diffHelp(aNode, bNode, localPatches, index);
			index += aNode.descendantsCount || 0;

			aIndex++;
			bIndex++;
			continue;
		}

		// look ahead 1 to detect insertions and removals.

		var aLookAhead = aIndex + 1 < aLen;
		var bLookAhead = bIndex + 1 < bLen;

		if (aLookAhead)
		{
			var aNext = aChildren[aIndex + 1];
			var aNextKey = aNext._0;
			var aNextNode = aNext._1;
			var oldMatch = bKey === aNextKey;
		}

		if (bLookAhead)
		{
			var bNext = bChildren[bIndex + 1];
			var bNextKey = bNext._0;
			var bNextNode = bNext._1;
			var newMatch = aKey === bNextKey;
		}


		// swap a and b
		if (aLookAhead && bLookAhead && newMatch && oldMatch)
		{
			index++;
			diffHelp(aNode, bNextNode, localPatches, index);
			insertNode(changes, localPatches, aKey, bNode, bIndex, inserts);
			index += aNode.descendantsCount || 0;

			index++;
			removeNode(changes, localPatches, aKey, aNextNode, index);
			index += aNextNode.descendantsCount || 0;

			aIndex += 2;
			bIndex += 2;
			continue;
		}

		// insert b
		if (bLookAhead && newMatch)
		{
			index++;
			insertNode(changes, localPatches, bKey, bNode, bIndex, inserts);
			diffHelp(aNode, bNextNode, localPatches, index);
			index += aNode.descendantsCount || 0;

			aIndex += 1;
			bIndex += 2;
			continue;
		}

		// remove a
		if (aLookAhead && oldMatch)
		{
			index++;
			removeNode(changes, localPatches, aKey, aNode, index);
			index += aNode.descendantsCount || 0;

			index++;
			diffHelp(aNextNode, bNode, localPatches, index);
			index += aNextNode.descendantsCount || 0;

			aIndex += 2;
			bIndex += 1;
			continue;
		}

		// remove a, insert b
		if (aLookAhead && bLookAhead && aNextKey === bNextKey)
		{
			index++;
			removeNode(changes, localPatches, aKey, aNode, index);
			insertNode(changes, localPatches, bKey, bNode, bIndex, inserts);
			index += aNode.descendantsCount || 0;

			index++;
			diffHelp(aNextNode, bNextNode, localPatches, index);
			index += aNextNode.descendantsCount || 0;

			aIndex += 2;
			bIndex += 2;
			continue;
		}

		break;
	}

	// eat up any remaining nodes with removeNode and insertNode

	while (aIndex < aLen)
	{
		index++;
		var a = aChildren[aIndex];
		var aNode = a._1;
		removeNode(changes, localPatches, a._0, aNode, index);
		index += aNode.descendantsCount || 0;
		aIndex++;
	}

	var endInserts;
	while (bIndex < bLen)
	{
		endInserts = endInserts || [];
		var b = bChildren[bIndex];
		insertNode(changes, localPatches, b._0, b._1, undefined, endInserts);
		bIndex++;
	}

	if (localPatches.length > 0 || inserts.length > 0 || typeof endInserts !== 'undefined')
	{
		patches.push(makePatch('p-reorder', rootIndex, {
			patches: localPatches,
			inserts: inserts,
			endInserts: endInserts
		}));
	}
}



////////////  CHANGES FROM KEYED DIFF  ////////////


var POSTFIX = '_elmW6BL';


function insertNode(changes, localPatches, key, vnode, bIndex, inserts)
{
	var entry = changes[key];

	// never seen this key before
	if (typeof entry === 'undefined')
	{
		entry = {
			tag: 'insert',
			vnode: vnode,
			index: bIndex,
			data: undefined
		};

		inserts.push({ index: bIndex, entry: entry });
		changes[key] = entry;

		return;
	}

	// this key was removed earlier, a match!
	if (entry.tag === 'remove')
	{
		inserts.push({ index: bIndex, entry: entry });

		entry.tag = 'move';
		var subPatches = [];
		diffHelp(entry.vnode, vnode, subPatches, entry.index);
		entry.index = bIndex;
		entry.data.data = {
			patches: subPatches,
			entry: entry
		};

		return;
	}

	// this key has already been inserted or moved, a duplicate!
	insertNode(changes, localPatches, key + POSTFIX, vnode, bIndex, inserts);
}


function removeNode(changes, localPatches, key, vnode, index)
{
	var entry = changes[key];

	// never seen this key before
	if (typeof entry === 'undefined')
	{
		var patch = makePatch('p-remove', index, undefined);
		localPatches.push(patch);

		changes[key] = {
			tag: 'remove',
			vnode: vnode,
			index: index,
			data: patch
		};

		return;
	}

	// this key was inserted earlier, a match!
	if (entry.tag === 'insert')
	{
		entry.tag = 'move';
		var subPatches = [];
		diffHelp(vnode, entry.vnode, subPatches, index);

		var patch = makePatch('p-remove', index, {
			patches: subPatches,
			entry: entry
		});
		localPatches.push(patch);

		return;
	}

	// this key has already been removed or moved, a duplicate!
	removeNode(changes, localPatches, key + POSTFIX, vnode, index);
}



////////////  ADD DOM NODES  ////////////
//
// Each DOM node has an "index" assigned in order of traversal. It is important
// to minimize our crawl over the actual DOM, so these indexes (along with the
// descendantsCount of virtual nodes) let us skip touching entire subtrees of
// the DOM if we know there are no patches there.


function addDomNodes(domNode, vNode, patches, eventNode)
{
	addDomNodesHelp(domNode, vNode, patches, 0, 0, vNode.descendantsCount, eventNode);
}


// assumes `patches` is non-empty and indexes increase monotonically.
function addDomNodesHelp(domNode, vNode, patches, i, low, high, eventNode)
{
	var patch = patches[i];
	var index = patch.index;

	while (index === low)
	{
		var patchType = patch.type;

		if (patchType === 'p-thunk')
		{
			addDomNodes(domNode, vNode.node, patch.data, eventNode);
		}
		else if (patchType === 'p-reorder')
		{
			patch.domNode = domNode;
			patch.eventNode = eventNode;

			var subPatches = patch.data.patches;
			if (subPatches.length > 0)
			{
				addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
			}
		}
		else if (patchType === 'p-remove')
		{
			patch.domNode = domNode;
			patch.eventNode = eventNode;

			var data = patch.data;
			if (typeof data !== 'undefined')
			{
				data.entry.data = domNode;
				var subPatches = data.patches;
				if (subPatches.length > 0)
				{
					addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
				}
			}
		}
		else
		{
			patch.domNode = domNode;
			patch.eventNode = eventNode;
		}

		i++;

		if (!(patch = patches[i]) || (index = patch.index) > high)
		{
			return i;
		}
	}

	switch (vNode.type)
	{
		case 'tagger':
			var subNode = vNode.node;

			while (subNode.type === "tagger")
			{
				subNode = subNode.node;
			}

			return addDomNodesHelp(domNode, subNode, patches, i, low + 1, high, domNode.elm_event_node_ref);

		case 'node':
			var vChildren = vNode.children;
			var childNodes = domNode.childNodes;
			for (var j = 0; j < vChildren.length; j++)
			{
				low++;
				var vChild = vChildren[j];
				var nextLow = low + (vChild.descendantsCount || 0);
				if (low <= index && index <= nextLow)
				{
					i = addDomNodesHelp(childNodes[j], vChild, patches, i, low, nextLow, eventNode);
					if (!(patch = patches[i]) || (index = patch.index) > high)
					{
						return i;
					}
				}
				low = nextLow;
			}
			return i;

		case 'keyed-node':
			var vChildren = vNode.children;
			var childNodes = domNode.childNodes;
			for (var j = 0; j < vChildren.length; j++)
			{
				low++;
				var vChild = vChildren[j]._1;
				var nextLow = low + (vChild.descendantsCount || 0);
				if (low <= index && index <= nextLow)
				{
					i = addDomNodesHelp(childNodes[j], vChild, patches, i, low, nextLow, eventNode);
					if (!(patch = patches[i]) || (index = patch.index) > high)
					{
						return i;
					}
				}
				low = nextLow;
			}
			return i;

		case 'text':
		case 'thunk':
			throw new Error('should never traverse `text` or `thunk` nodes like this');
	}
}



////////////  APPLY PATCHES  ////////////


function applyPatches(rootDomNode, oldVirtualNode, patches, eventNode)
{
	if (patches.length === 0)
	{
		return rootDomNode;
	}

	addDomNodes(rootDomNode, oldVirtualNode, patches, eventNode);
	return applyPatchesHelp(rootDomNode, patches);
}

function applyPatchesHelp(rootDomNode, patches)
{
	for (var i = 0; i < patches.length; i++)
	{
		var patch = patches[i];
		var localDomNode = patch.domNode
		var newNode = applyPatch(localDomNode, patch);
		if (localDomNode === rootDomNode)
		{
			rootDomNode = newNode;
		}
	}
	return rootDomNode;
}

function applyPatch(domNode, patch)
{
	switch (patch.type)
	{
		case 'p-redraw':
			return applyPatchRedraw(domNode, patch.data, patch.eventNode);

		case 'p-facts':
			applyFacts(domNode, patch.eventNode, patch.data);
			return domNode;

		case 'p-text':
			domNode.replaceData(0, domNode.length, patch.data);
			return domNode;

		case 'p-thunk':
			return applyPatchesHelp(domNode, patch.data);

		case 'p-tagger':
			if (typeof domNode.elm_event_node_ref !== 'undefined')
			{
				domNode.elm_event_node_ref.tagger = patch.data;
			}
			else
			{
				domNode.elm_event_node_ref = { tagger: patch.data, parent: patch.eventNode };
			}
			return domNode;

		case 'p-remove-last':
			var i = patch.data;
			while (i--)
			{
				domNode.removeChild(domNode.lastChild);
			}
			return domNode;

		case 'p-append':
			var newNodes = patch.data;
			for (var i = 0; i < newNodes.length; i++)
			{
				domNode.appendChild(render(newNodes[i], patch.eventNode));
			}
			return domNode;

		case 'p-remove':
			var data = patch.data;
			if (typeof data === 'undefined')
			{
				domNode.parentNode.removeChild(domNode);
				return domNode;
			}
			var entry = data.entry;
			if (typeof entry.index !== 'undefined')
			{
				domNode.parentNode.removeChild(domNode);
			}
			entry.data = applyPatchesHelp(domNode, data.patches);
			return domNode;

		case 'p-reorder':
			return applyPatchReorder(domNode, patch);

		case 'p-custom':
			var impl = patch.data;
			return impl.applyPatch(domNode, impl.data);

		default:
			throw new Error('Ran into an unknown patch!');
	}
}


function applyPatchRedraw(domNode, vNode, eventNode)
{
	var parentNode = domNode.parentNode;
	var newNode = render(vNode, eventNode);

	if (typeof newNode.elm_event_node_ref === 'undefined')
	{
		newNode.elm_event_node_ref = domNode.elm_event_node_ref;
	}

	if (parentNode && newNode !== domNode)
	{
		parentNode.replaceChild(newNode, domNode);
	}
	return newNode;
}


function applyPatchReorder(domNode, patch)
{
	var data = patch.data;

	// remove end inserts
	var frag = applyPatchReorderEndInsertsHelp(data.endInserts, patch);

	// removals
	domNode = applyPatchesHelp(domNode, data.patches);

	// inserts
	var inserts = data.inserts;
	for (var i = 0; i < inserts.length; i++)
	{
		var insert = inserts[i];
		var entry = insert.entry;
		var node = entry.tag === 'move'
			? entry.data
			: render(entry.vnode, patch.eventNode);
		domNode.insertBefore(node, domNode.childNodes[insert.index]);
	}

	// add end inserts
	if (typeof frag !== 'undefined')
	{
		domNode.appendChild(frag);
	}

	return domNode;
}


function applyPatchReorderEndInsertsHelp(endInserts, patch)
{
	if (typeof endInserts === 'undefined')
	{
		return;
	}

	var frag = localDoc.createDocumentFragment();
	for (var i = 0; i < endInserts.length; i++)
	{
		var insert = endInserts[i];
		var entry = insert.entry;
		frag.appendChild(entry.tag === 'move'
			? entry.data
			: render(entry.vnode, patch.eventNode)
		);
	}
	return frag;
}


// PROGRAMS

var program = makeProgram(checkNoFlags);
var programWithFlags = makeProgram(checkYesFlags);

function makeProgram(flagChecker)
{
	return F2(function(debugWrap, impl)
	{
		return function(flagDecoder)
		{
			return function(object, moduleName, debugMetadata)
			{
				var checker = flagChecker(flagDecoder, moduleName);
				if (typeof debugMetadata === 'undefined')
				{
					normalSetup(impl, object, moduleName, checker);
				}
				else
				{
					debugSetup(A2(debugWrap, debugMetadata, impl), object, moduleName, checker);
				}
			};
		};
	});
}

function staticProgram(vNode)
{
	var nothing = _elm_lang$core$Native_Utils.Tuple2(
		_elm_lang$core$Native_Utils.Tuple0,
		_elm_lang$core$Platform_Cmd$none
	);
	return A2(program, _elm_lang$virtual_dom$VirtualDom_Debug$wrap, {
		init: nothing,
		view: function() { return vNode; },
		update: F2(function() { return nothing; }),
		subscriptions: function() { return _elm_lang$core$Platform_Sub$none; }
	})();
}


// FLAG CHECKERS

function checkNoFlags(flagDecoder, moduleName)
{
	return function(init, flags, domNode)
	{
		if (typeof flags === 'undefined')
		{
			return init;
		}

		var errorMessage =
			'The `' + moduleName + '` module does not need flags.\n'
			+ 'Initialize it with no arguments and you should be all set!';

		crash(errorMessage, domNode);
	};
}

function checkYesFlags(flagDecoder, moduleName)
{
	return function(init, flags, domNode)
	{
		if (typeof flagDecoder === 'undefined')
		{
			var errorMessage =
				'Are you trying to sneak a Never value into Elm? Trickster!\n'
				+ 'It looks like ' + moduleName + '.main is defined with `programWithFlags` but has type `Program Never`.\n'
				+ 'Use `program` instead if you do not want flags.'

			crash(errorMessage, domNode);
		}

		var result = A2(_elm_lang$core$Native_Json.run, flagDecoder, flags);
		if (result.ctor === 'Ok')
		{
			return init(result._0);
		}

		var errorMessage =
			'Trying to initialize the `' + moduleName + '` module with an unexpected flag.\n'
			+ 'I tried to convert it to an Elm value, but ran into this problem:\n\n'
			+ result._0;

		crash(errorMessage, domNode);
	};
}

function crash(errorMessage, domNode)
{
	if (domNode)
	{
		domNode.innerHTML =
			'<div style="padding-left:1em;">'
			+ '<h2 style="font-weight:normal;"><b>Oops!</b> Something went wrong when starting your Elm program.</h2>'
			+ '<pre style="padding-left:1em;">' + errorMessage + '</pre>'
			+ '</div>';
	}

	throw new Error(errorMessage);
}


//  NORMAL SETUP

function normalSetup(impl, object, moduleName, flagChecker)
{
	object['embed'] = function embed(node, flags)
	{
		while (node.lastChild)
		{
			node.removeChild(node.lastChild);
		}

		return _elm_lang$core$Native_Platform.initialize(
			flagChecker(impl.init, flags, node),
			impl.update,
			impl.subscriptions,
			normalRenderer(node, impl.view)
		);
	};

	object['fullscreen'] = function fullscreen(flags)
	{
		return _elm_lang$core$Native_Platform.initialize(
			flagChecker(impl.init, flags, document.body),
			impl.update,
			impl.subscriptions,
			normalRenderer(document.body, impl.view)
		);
	};
}

function normalRenderer(parentNode, view)
{
	return function(tagger, initialModel)
	{
		var eventNode = { tagger: tagger, parent: undefined };
		var initialVirtualNode = view(initialModel);
		var domNode = render(initialVirtualNode, eventNode);
		parentNode.appendChild(domNode);
		return makeStepper(domNode, view, initialVirtualNode, eventNode);
	};
}


// STEPPER

var rAF =
	typeof requestAnimationFrame !== 'undefined'
		? requestAnimationFrame
		: function(callback) { callback(); };

function makeStepper(domNode, view, initialVirtualNode, eventNode)
{
	var state = 'NO_REQUEST';
	var currNode = initialVirtualNode;
	var nextModel;

	function updateIfNeeded()
	{
		switch (state)
		{
			case 'NO_REQUEST':
				throw new Error(
					'Unexpected draw callback.\n' +
					'Please report this to <https://github.com/elm-lang/virtual-dom/issues>.'
				);

			case 'PENDING_REQUEST':
				rAF(updateIfNeeded);
				state = 'EXTRA_REQUEST';

				var nextNode = view(nextModel);
				var patches = diff(currNode, nextNode);
				domNode = applyPatches(domNode, currNode, patches, eventNode);
				currNode = nextNode;

				return;

			case 'EXTRA_REQUEST':
				state = 'NO_REQUEST';
				return;
		}
	}

	return function stepper(model)
	{
		if (state === 'NO_REQUEST')
		{
			rAF(updateIfNeeded);
		}
		state = 'PENDING_REQUEST';
		nextModel = model;
	};
}


// DEBUG SETUP

function debugSetup(impl, object, moduleName, flagChecker)
{
	object['fullscreen'] = function fullscreen(flags)
	{
		var popoutRef = { doc: undefined };
		return _elm_lang$core$Native_Platform.initialize(
			flagChecker(impl.init, flags, document.body),
			impl.update(scrollTask(popoutRef)),
			impl.subscriptions,
			debugRenderer(moduleName, document.body, popoutRef, impl.view, impl.viewIn, impl.viewOut)
		);
	};

	object['embed'] = function fullscreen(node, flags)
	{
		var popoutRef = { doc: undefined };
		return _elm_lang$core$Native_Platform.initialize(
			flagChecker(impl.init, flags, node),
			impl.update(scrollTask(popoutRef)),
			impl.subscriptions,
			debugRenderer(moduleName, node, popoutRef, impl.view, impl.viewIn, impl.viewOut)
		);
	};
}

function scrollTask(popoutRef)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		var doc = popoutRef.doc;
		if (doc)
		{
			var msgs = doc.getElementsByClassName('debugger-sidebar-messages')[0];
			if (msgs)
			{
				msgs.scrollTop = msgs.scrollHeight;
			}
		}
		callback(_elm_lang$core$Native_Scheduler.succeed(_elm_lang$core$Native_Utils.Tuple0));
	});
}


function debugRenderer(moduleName, parentNode, popoutRef, view, viewIn, viewOut)
{
	return function(tagger, initialModel)
	{
		var appEventNode = { tagger: tagger, parent: undefined };
		var eventNode = { tagger: tagger, parent: undefined };

		// make normal stepper
		var appVirtualNode = view(initialModel);
		var appNode = render(appVirtualNode, appEventNode);
		parentNode.appendChild(appNode);
		var appStepper = makeStepper(appNode, view, appVirtualNode, appEventNode);

		// make overlay stepper
		var overVirtualNode = viewIn(initialModel)._1;
		var overNode = render(overVirtualNode, eventNode);
		parentNode.appendChild(overNode);
		var wrappedViewIn = wrapViewIn(appEventNode, overNode, viewIn);
		var overStepper = makeStepper(overNode, wrappedViewIn, overVirtualNode, eventNode);

		// make debugger stepper
		var debugStepper = makeDebugStepper(initialModel, viewOut, eventNode, parentNode, moduleName, popoutRef);

		return function stepper(model)
		{
			appStepper(model);
			overStepper(model);
			debugStepper(model);
		}
	};
}

function makeDebugStepper(initialModel, view, eventNode, parentNode, moduleName, popoutRef)
{
	var curr;
	var domNode;

	return function stepper(model)
	{
		if (!model.isDebuggerOpen)
		{
			return;
		}

		if (!popoutRef.doc)
		{
			curr = view(model);
			domNode = openDebugWindow(moduleName, popoutRef, curr, eventNode);
			return;
		}

		// switch to document of popout
		localDoc = popoutRef.doc;

		var next = view(model);
		var patches = diff(curr, next);
		domNode = applyPatches(domNode, curr, patches, eventNode);
		curr = next;

		// switch back to normal document
		localDoc = document;
	};
}

function openDebugWindow(moduleName, popoutRef, virtualNode, eventNode)
{
	var w = 900;
	var h = 360;
	var x = screen.width - w;
	var y = screen.height - h;
	var debugWindow = window.open('', '', 'width=' + w + ',height=' + h + ',left=' + x + ',top=' + y);

	// switch to window document
	localDoc = debugWindow.document;

	popoutRef.doc = localDoc;
	localDoc.title = 'Debugger - ' + moduleName;
	localDoc.body.style.margin = '0';
	localDoc.body.style.padding = '0';
	var domNode = render(virtualNode, eventNode);
	localDoc.body.appendChild(domNode);

	localDoc.addEventListener('keydown', function(event) {
		if (event.metaKey && event.which === 82)
		{
			window.location.reload();
		}
		if (event.which === 38)
		{
			eventNode.tagger({ ctor: 'Up' });
			event.preventDefault();
		}
		if (event.which === 40)
		{
			eventNode.tagger({ ctor: 'Down' });
			event.preventDefault();
		}
	});

	function close()
	{
		popoutRef.doc = undefined;
		debugWindow.close();
	}
	window.addEventListener('unload', close);
	debugWindow.addEventListener('unload', function() {
		popoutRef.doc = undefined;
		window.removeEventListener('unload', close);
		eventNode.tagger({ ctor: 'Close' });
	});

	// switch back to the normal document
	localDoc = document;

	return domNode;
}


// BLOCK EVENTS

function wrapViewIn(appEventNode, overlayNode, viewIn)
{
	var ignorer = makeIgnorer(overlayNode);
	var blocking = 'Normal';
	var overflow;

	var normalTagger = appEventNode.tagger;
	var blockTagger = function() {};

	return function(model)
	{
		var tuple = viewIn(model);
		var newBlocking = tuple._0.ctor;
		appEventNode.tagger = newBlocking === 'Normal' ? normalTagger : blockTagger;
		if (blocking !== newBlocking)
		{
			traverse('removeEventListener', ignorer, blocking);
			traverse('addEventListener', ignorer, newBlocking);

			if (blocking === 'Normal')
			{
				overflow = document.body.style.overflow;
				document.body.style.overflow = 'hidden';
			}

			if (newBlocking === 'Normal')
			{
				document.body.style.overflow = overflow;
			}

			blocking = newBlocking;
		}
		return tuple._1;
	}
}

function traverse(verbEventListener, ignorer, blocking)
{
	switch(blocking)
	{
		case 'Normal':
			return;

		case 'Pause':
			return traverseHelp(verbEventListener, ignorer, mostEvents);

		case 'Message':
			return traverseHelp(verbEventListener, ignorer, allEvents);
	}
}

function traverseHelp(verbEventListener, handler, eventNames)
{
	for (var i = 0; i < eventNames.length; i++)
	{
		document.body[verbEventListener](eventNames[i], handler, true);
	}
}

function makeIgnorer(overlayNode)
{
	return function(event)
	{
		if (event.type === 'keydown' && event.metaKey && event.which === 82)
		{
			return;
		}

		var isScroll = event.type === 'scroll' || event.type === 'wheel';

		var node = event.target;
		while (node !== null)
		{
			if (node.className === 'elm-overlay-message-details' && isScroll)
			{
				return;
			}

			if (node === overlayNode && !isScroll)
			{
				return;
			}
			node = node.parentNode;
		}

		event.stopPropagation();
		event.preventDefault();
	}
}

var mostEvents = [
	'click', 'dblclick', 'mousemove',
	'mouseup', 'mousedown', 'mouseenter', 'mouseleave',
	'touchstart', 'touchend', 'touchcancel', 'touchmove',
	'pointerdown', 'pointerup', 'pointerover', 'pointerout',
	'pointerenter', 'pointerleave', 'pointermove', 'pointercancel',
	'dragstart', 'drag', 'dragend', 'dragenter', 'dragover', 'dragleave', 'drop',
	'keyup', 'keydown', 'keypress',
	'input', 'change',
	'focus', 'blur'
];

var allEvents = mostEvents.concat('wheel', 'scroll');


return {
	node: node,
	text: text,
	custom: custom,
	map: F2(map),

	on: F3(on),
	style: style,
	property: F2(property),
	attribute: F2(attribute),
	attributeNS: F3(attributeNS),
	mapProperty: F2(mapProperty),

	lazy: F2(lazy),
	lazy2: F3(lazy2),
	lazy3: F4(lazy3),
	keyedNode: F3(keyedNode),

	program: program,
	programWithFlags: programWithFlags,
	staticProgram: staticProgram
};

}();

var _elm_lang$virtual_dom$VirtualDom$programWithFlags = function (impl) {
	return A2(_elm_lang$virtual_dom$Native_VirtualDom.programWithFlags, _elm_lang$virtual_dom$VirtualDom_Debug$wrapWithFlags, impl);
};
var _elm_lang$virtual_dom$VirtualDom$program = function (impl) {
	return A2(_elm_lang$virtual_dom$Native_VirtualDom.program, _elm_lang$virtual_dom$VirtualDom_Debug$wrap, impl);
};
var _elm_lang$virtual_dom$VirtualDom$keyedNode = _elm_lang$virtual_dom$Native_VirtualDom.keyedNode;
var _elm_lang$virtual_dom$VirtualDom$lazy3 = _elm_lang$virtual_dom$Native_VirtualDom.lazy3;
var _elm_lang$virtual_dom$VirtualDom$lazy2 = _elm_lang$virtual_dom$Native_VirtualDom.lazy2;
var _elm_lang$virtual_dom$VirtualDom$lazy = _elm_lang$virtual_dom$Native_VirtualDom.lazy;
var _elm_lang$virtual_dom$VirtualDom$defaultOptions = {stopPropagation: false, preventDefault: false};
var _elm_lang$virtual_dom$VirtualDom$onWithOptions = _elm_lang$virtual_dom$Native_VirtualDom.on;
var _elm_lang$virtual_dom$VirtualDom$on = F2(
	function (eventName, decoder) {
		return A3(_elm_lang$virtual_dom$VirtualDom$onWithOptions, eventName, _elm_lang$virtual_dom$VirtualDom$defaultOptions, decoder);
	});
var _elm_lang$virtual_dom$VirtualDom$style = _elm_lang$virtual_dom$Native_VirtualDom.style;
var _elm_lang$virtual_dom$VirtualDom$mapProperty = _elm_lang$virtual_dom$Native_VirtualDom.mapProperty;
var _elm_lang$virtual_dom$VirtualDom$attributeNS = _elm_lang$virtual_dom$Native_VirtualDom.attributeNS;
var _elm_lang$virtual_dom$VirtualDom$attribute = _elm_lang$virtual_dom$Native_VirtualDom.attribute;
var _elm_lang$virtual_dom$VirtualDom$property = _elm_lang$virtual_dom$Native_VirtualDom.property;
var _elm_lang$virtual_dom$VirtualDom$map = _elm_lang$virtual_dom$Native_VirtualDom.map;
var _elm_lang$virtual_dom$VirtualDom$text = _elm_lang$virtual_dom$Native_VirtualDom.text;
var _elm_lang$virtual_dom$VirtualDom$node = _elm_lang$virtual_dom$Native_VirtualDom.node;
var _elm_lang$virtual_dom$VirtualDom$Options = F2(
	function (a, b) {
		return {stopPropagation: a, preventDefault: b};
	});
var _elm_lang$virtual_dom$VirtualDom$Node = {ctor: 'Node'};
var _elm_lang$virtual_dom$VirtualDom$Property = {ctor: 'Property'};

var _elm_lang$html$Html$programWithFlags = _elm_lang$virtual_dom$VirtualDom$programWithFlags;
var _elm_lang$html$Html$program = _elm_lang$virtual_dom$VirtualDom$program;
var _elm_lang$html$Html$beginnerProgram = function (_p0) {
	var _p1 = _p0;
	return _elm_lang$html$Html$program(
		{
			init: A2(
				_elm_lang$core$Platform_Cmd_ops['!'],
				_p1.model,
				{ctor: '[]'}),
			update: F2(
				function (msg, model) {
					return A2(
						_elm_lang$core$Platform_Cmd_ops['!'],
						A2(_p1.update, msg, model),
						{ctor: '[]'});
				}),
			view: _p1.view,
			subscriptions: function (_p2) {
				return _elm_lang$core$Platform_Sub$none;
			}
		});
};
var _elm_lang$html$Html$map = _elm_lang$virtual_dom$VirtualDom$map;
var _elm_lang$html$Html$text = _elm_lang$virtual_dom$VirtualDom$text;
var _elm_lang$html$Html$node = _elm_lang$virtual_dom$VirtualDom$node;
var _elm_lang$html$Html$body = _elm_lang$html$Html$node('body');
var _elm_lang$html$Html$section = _elm_lang$html$Html$node('section');
var _elm_lang$html$Html$nav = _elm_lang$html$Html$node('nav');
var _elm_lang$html$Html$article = _elm_lang$html$Html$node('article');
var _elm_lang$html$Html$aside = _elm_lang$html$Html$node('aside');
var _elm_lang$html$Html$h1 = _elm_lang$html$Html$node('h1');
var _elm_lang$html$Html$h2 = _elm_lang$html$Html$node('h2');
var _elm_lang$html$Html$h3 = _elm_lang$html$Html$node('h3');
var _elm_lang$html$Html$h4 = _elm_lang$html$Html$node('h4');
var _elm_lang$html$Html$h5 = _elm_lang$html$Html$node('h5');
var _elm_lang$html$Html$h6 = _elm_lang$html$Html$node('h6');
var _elm_lang$html$Html$header = _elm_lang$html$Html$node('header');
var _elm_lang$html$Html$footer = _elm_lang$html$Html$node('footer');
var _elm_lang$html$Html$address = _elm_lang$html$Html$node('address');
var _elm_lang$html$Html$main_ = _elm_lang$html$Html$node('main');
var _elm_lang$html$Html$p = _elm_lang$html$Html$node('p');
var _elm_lang$html$Html$hr = _elm_lang$html$Html$node('hr');
var _elm_lang$html$Html$pre = _elm_lang$html$Html$node('pre');
var _elm_lang$html$Html$blockquote = _elm_lang$html$Html$node('blockquote');
var _elm_lang$html$Html$ol = _elm_lang$html$Html$node('ol');
var _elm_lang$html$Html$ul = _elm_lang$html$Html$node('ul');
var _elm_lang$html$Html$li = _elm_lang$html$Html$node('li');
var _elm_lang$html$Html$dl = _elm_lang$html$Html$node('dl');
var _elm_lang$html$Html$dt = _elm_lang$html$Html$node('dt');
var _elm_lang$html$Html$dd = _elm_lang$html$Html$node('dd');
var _elm_lang$html$Html$figure = _elm_lang$html$Html$node('figure');
var _elm_lang$html$Html$figcaption = _elm_lang$html$Html$node('figcaption');
var _elm_lang$html$Html$div = _elm_lang$html$Html$node('div');
var _elm_lang$html$Html$a = _elm_lang$html$Html$node('a');
var _elm_lang$html$Html$em = _elm_lang$html$Html$node('em');
var _elm_lang$html$Html$strong = _elm_lang$html$Html$node('strong');
var _elm_lang$html$Html$small = _elm_lang$html$Html$node('small');
var _elm_lang$html$Html$s = _elm_lang$html$Html$node('s');
var _elm_lang$html$Html$cite = _elm_lang$html$Html$node('cite');
var _elm_lang$html$Html$q = _elm_lang$html$Html$node('q');
var _elm_lang$html$Html$dfn = _elm_lang$html$Html$node('dfn');
var _elm_lang$html$Html$abbr = _elm_lang$html$Html$node('abbr');
var _elm_lang$html$Html$time = _elm_lang$html$Html$node('time');
var _elm_lang$html$Html$code = _elm_lang$html$Html$node('code');
var _elm_lang$html$Html$var = _elm_lang$html$Html$node('var');
var _elm_lang$html$Html$samp = _elm_lang$html$Html$node('samp');
var _elm_lang$html$Html$kbd = _elm_lang$html$Html$node('kbd');
var _elm_lang$html$Html$sub = _elm_lang$html$Html$node('sub');
var _elm_lang$html$Html$sup = _elm_lang$html$Html$node('sup');
var _elm_lang$html$Html$i = _elm_lang$html$Html$node('i');
var _elm_lang$html$Html$b = _elm_lang$html$Html$node('b');
var _elm_lang$html$Html$u = _elm_lang$html$Html$node('u');
var _elm_lang$html$Html$mark = _elm_lang$html$Html$node('mark');
var _elm_lang$html$Html$ruby = _elm_lang$html$Html$node('ruby');
var _elm_lang$html$Html$rt = _elm_lang$html$Html$node('rt');
var _elm_lang$html$Html$rp = _elm_lang$html$Html$node('rp');
var _elm_lang$html$Html$bdi = _elm_lang$html$Html$node('bdi');
var _elm_lang$html$Html$bdo = _elm_lang$html$Html$node('bdo');
var _elm_lang$html$Html$span = _elm_lang$html$Html$node('span');
var _elm_lang$html$Html$br = _elm_lang$html$Html$node('br');
var _elm_lang$html$Html$wbr = _elm_lang$html$Html$node('wbr');
var _elm_lang$html$Html$ins = _elm_lang$html$Html$node('ins');
var _elm_lang$html$Html$del = _elm_lang$html$Html$node('del');
var _elm_lang$html$Html$img = _elm_lang$html$Html$node('img');
var _elm_lang$html$Html$iframe = _elm_lang$html$Html$node('iframe');
var _elm_lang$html$Html$embed = _elm_lang$html$Html$node('embed');
var _elm_lang$html$Html$object = _elm_lang$html$Html$node('object');
var _elm_lang$html$Html$param = _elm_lang$html$Html$node('param');
var _elm_lang$html$Html$video = _elm_lang$html$Html$node('video');
var _elm_lang$html$Html$audio = _elm_lang$html$Html$node('audio');
var _elm_lang$html$Html$source = _elm_lang$html$Html$node('source');
var _elm_lang$html$Html$track = _elm_lang$html$Html$node('track');
var _elm_lang$html$Html$canvas = _elm_lang$html$Html$node('canvas');
var _elm_lang$html$Html$math = _elm_lang$html$Html$node('math');
var _elm_lang$html$Html$table = _elm_lang$html$Html$node('table');
var _elm_lang$html$Html$caption = _elm_lang$html$Html$node('caption');
var _elm_lang$html$Html$colgroup = _elm_lang$html$Html$node('colgroup');
var _elm_lang$html$Html$col = _elm_lang$html$Html$node('col');
var _elm_lang$html$Html$tbody = _elm_lang$html$Html$node('tbody');
var _elm_lang$html$Html$thead = _elm_lang$html$Html$node('thead');
var _elm_lang$html$Html$tfoot = _elm_lang$html$Html$node('tfoot');
var _elm_lang$html$Html$tr = _elm_lang$html$Html$node('tr');
var _elm_lang$html$Html$td = _elm_lang$html$Html$node('td');
var _elm_lang$html$Html$th = _elm_lang$html$Html$node('th');
var _elm_lang$html$Html$form = _elm_lang$html$Html$node('form');
var _elm_lang$html$Html$fieldset = _elm_lang$html$Html$node('fieldset');
var _elm_lang$html$Html$legend = _elm_lang$html$Html$node('legend');
var _elm_lang$html$Html$label = _elm_lang$html$Html$node('label');
var _elm_lang$html$Html$input = _elm_lang$html$Html$node('input');
var _elm_lang$html$Html$button = _elm_lang$html$Html$node('button');
var _elm_lang$html$Html$select = _elm_lang$html$Html$node('select');
var _elm_lang$html$Html$datalist = _elm_lang$html$Html$node('datalist');
var _elm_lang$html$Html$optgroup = _elm_lang$html$Html$node('optgroup');
var _elm_lang$html$Html$option = _elm_lang$html$Html$node('option');
var _elm_lang$html$Html$textarea = _elm_lang$html$Html$node('textarea');
var _elm_lang$html$Html$keygen = _elm_lang$html$Html$node('keygen');
var _elm_lang$html$Html$output = _elm_lang$html$Html$node('output');
var _elm_lang$html$Html$progress = _elm_lang$html$Html$node('progress');
var _elm_lang$html$Html$meter = _elm_lang$html$Html$node('meter');
var _elm_lang$html$Html$details = _elm_lang$html$Html$node('details');
var _elm_lang$html$Html$summary = _elm_lang$html$Html$node('summary');
var _elm_lang$html$Html$menuitem = _elm_lang$html$Html$node('menuitem');
var _elm_lang$html$Html$menu = _elm_lang$html$Html$node('menu');

var _elm_lang$html$Html_Attributes$map = _elm_lang$virtual_dom$VirtualDom$mapProperty;
var _elm_lang$html$Html_Attributes$attribute = _elm_lang$virtual_dom$VirtualDom$attribute;
var _elm_lang$html$Html_Attributes$contextmenu = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'contextmenu', value);
};
var _elm_lang$html$Html_Attributes$draggable = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'draggable', value);
};
var _elm_lang$html$Html_Attributes$itemprop = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'itemprop', value);
};
var _elm_lang$html$Html_Attributes$tabindex = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'tabIndex',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$charset = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'charset', value);
};
var _elm_lang$html$Html_Attributes$height = function (value) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'height',
		_elm_lang$core$Basics$toString(value));
};
var _elm_lang$html$Html_Attributes$width = function (value) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'width',
		_elm_lang$core$Basics$toString(value));
};
var _elm_lang$html$Html_Attributes$formaction = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'formAction', value);
};
var _elm_lang$html$Html_Attributes$list = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'list', value);
};
var _elm_lang$html$Html_Attributes$minlength = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'minLength',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$maxlength = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'maxlength',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$size = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'size',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$form = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'form', value);
};
var _elm_lang$html$Html_Attributes$cols = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'cols',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$rows = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'rows',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$challenge = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'challenge', value);
};
var _elm_lang$html$Html_Attributes$media = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'media', value);
};
var _elm_lang$html$Html_Attributes$rel = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'rel', value);
};
var _elm_lang$html$Html_Attributes$datetime = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'datetime', value);
};
var _elm_lang$html$Html_Attributes$pubdate = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'pubdate', value);
};
var _elm_lang$html$Html_Attributes$colspan = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'colspan',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$rowspan = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'rowspan',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$manifest = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'manifest', value);
};
var _elm_lang$html$Html_Attributes$property = _elm_lang$virtual_dom$VirtualDom$property;
var _elm_lang$html$Html_Attributes$stringProperty = F2(
	function (name, string) {
		return A2(
			_elm_lang$html$Html_Attributes$property,
			name,
			_elm_lang$core$Json_Encode$string(string));
	});
var _elm_lang$html$Html_Attributes$class = function (name) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'className', name);
};
var _elm_lang$html$Html_Attributes$id = function (name) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'id', name);
};
var _elm_lang$html$Html_Attributes$title = function (name) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'title', name);
};
var _elm_lang$html$Html_Attributes$accesskey = function ($char) {
	return A2(
		_elm_lang$html$Html_Attributes$stringProperty,
		'accessKey',
		_elm_lang$core$String$fromChar($char));
};
var _elm_lang$html$Html_Attributes$dir = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'dir', value);
};
var _elm_lang$html$Html_Attributes$dropzone = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'dropzone', value);
};
var _elm_lang$html$Html_Attributes$lang = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'lang', value);
};
var _elm_lang$html$Html_Attributes$content = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'content', value);
};
var _elm_lang$html$Html_Attributes$httpEquiv = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'httpEquiv', value);
};
var _elm_lang$html$Html_Attributes$language = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'language', value);
};
var _elm_lang$html$Html_Attributes$src = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'src', value);
};
var _elm_lang$html$Html_Attributes$alt = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'alt', value);
};
var _elm_lang$html$Html_Attributes$preload = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'preload', value);
};
var _elm_lang$html$Html_Attributes$poster = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'poster', value);
};
var _elm_lang$html$Html_Attributes$kind = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'kind', value);
};
var _elm_lang$html$Html_Attributes$srclang = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'srclang', value);
};
var _elm_lang$html$Html_Attributes$sandbox = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'sandbox', value);
};
var _elm_lang$html$Html_Attributes$srcdoc = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'srcdoc', value);
};
var _elm_lang$html$Html_Attributes$type_ = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'type', value);
};
var _elm_lang$html$Html_Attributes$value = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'value', value);
};
var _elm_lang$html$Html_Attributes$defaultValue = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'defaultValue', value);
};
var _elm_lang$html$Html_Attributes$placeholder = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'placeholder', value);
};
var _elm_lang$html$Html_Attributes$accept = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'accept', value);
};
var _elm_lang$html$Html_Attributes$acceptCharset = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'acceptCharset', value);
};
var _elm_lang$html$Html_Attributes$action = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'action', value);
};
var _elm_lang$html$Html_Attributes$autocomplete = function (bool) {
	return A2(
		_elm_lang$html$Html_Attributes$stringProperty,
		'autocomplete',
		bool ? 'on' : 'off');
};
var _elm_lang$html$Html_Attributes$enctype = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'enctype', value);
};
var _elm_lang$html$Html_Attributes$method = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'method', value);
};
var _elm_lang$html$Html_Attributes$name = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'name', value);
};
var _elm_lang$html$Html_Attributes$pattern = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'pattern', value);
};
var _elm_lang$html$Html_Attributes$for = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'htmlFor', value);
};
var _elm_lang$html$Html_Attributes$max = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'max', value);
};
var _elm_lang$html$Html_Attributes$min = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'min', value);
};
var _elm_lang$html$Html_Attributes$step = function (n) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'step', n);
};
var _elm_lang$html$Html_Attributes$wrap = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'wrap', value);
};
var _elm_lang$html$Html_Attributes$usemap = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'useMap', value);
};
var _elm_lang$html$Html_Attributes$shape = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'shape', value);
};
var _elm_lang$html$Html_Attributes$coords = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'coords', value);
};
var _elm_lang$html$Html_Attributes$keytype = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'keytype', value);
};
var _elm_lang$html$Html_Attributes$align = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'align', value);
};
var _elm_lang$html$Html_Attributes$cite = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'cite', value);
};
var _elm_lang$html$Html_Attributes$href = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'href', value);
};
var _elm_lang$html$Html_Attributes$target = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'target', value);
};
var _elm_lang$html$Html_Attributes$downloadAs = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'download', value);
};
var _elm_lang$html$Html_Attributes$hreflang = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'hreflang', value);
};
var _elm_lang$html$Html_Attributes$ping = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'ping', value);
};
var _elm_lang$html$Html_Attributes$start = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$stringProperty,
		'start',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$headers = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'headers', value);
};
var _elm_lang$html$Html_Attributes$scope = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'scope', value);
};
var _elm_lang$html$Html_Attributes$boolProperty = F2(
	function (name, bool) {
		return A2(
			_elm_lang$html$Html_Attributes$property,
			name,
			_elm_lang$core$Json_Encode$bool(bool));
	});
var _elm_lang$html$Html_Attributes$hidden = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'hidden', bool);
};
var _elm_lang$html$Html_Attributes$contenteditable = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'contentEditable', bool);
};
var _elm_lang$html$Html_Attributes$spellcheck = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'spellcheck', bool);
};
var _elm_lang$html$Html_Attributes$async = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'async', bool);
};
var _elm_lang$html$Html_Attributes$defer = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'defer', bool);
};
var _elm_lang$html$Html_Attributes$scoped = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'scoped', bool);
};
var _elm_lang$html$Html_Attributes$autoplay = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'autoplay', bool);
};
var _elm_lang$html$Html_Attributes$controls = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'controls', bool);
};
var _elm_lang$html$Html_Attributes$loop = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'loop', bool);
};
var _elm_lang$html$Html_Attributes$default = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'default', bool);
};
var _elm_lang$html$Html_Attributes$seamless = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'seamless', bool);
};
var _elm_lang$html$Html_Attributes$checked = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'checked', bool);
};
var _elm_lang$html$Html_Attributes$selected = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'selected', bool);
};
var _elm_lang$html$Html_Attributes$autofocus = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'autofocus', bool);
};
var _elm_lang$html$Html_Attributes$disabled = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'disabled', bool);
};
var _elm_lang$html$Html_Attributes$multiple = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'multiple', bool);
};
var _elm_lang$html$Html_Attributes$novalidate = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'noValidate', bool);
};
var _elm_lang$html$Html_Attributes$readonly = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'readOnly', bool);
};
var _elm_lang$html$Html_Attributes$required = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'required', bool);
};
var _elm_lang$html$Html_Attributes$ismap = function (value) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'isMap', value);
};
var _elm_lang$html$Html_Attributes$download = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'download', bool);
};
var _elm_lang$html$Html_Attributes$reversed = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'reversed', bool);
};
var _elm_lang$html$Html_Attributes$classList = function (list) {
	return _elm_lang$html$Html_Attributes$class(
		A2(
			_elm_lang$core$String$join,
			' ',
			A2(
				_elm_lang$core$List$map,
				_elm_lang$core$Tuple$first,
				A2(_elm_lang$core$List$filter, _elm_lang$core$Tuple$second, list))));
};
var _elm_lang$html$Html_Attributes$style = _elm_lang$virtual_dom$VirtualDom$style;

var _elm_lang$html$Html_Events$keyCode = A2(_elm_lang$core$Json_Decode$field, 'keyCode', _elm_lang$core$Json_Decode$int);
var _elm_lang$html$Html_Events$targetChecked = A2(
	_elm_lang$core$Json_Decode$at,
	{
		ctor: '::',
		_0: 'target',
		_1: {
			ctor: '::',
			_0: 'checked',
			_1: {ctor: '[]'}
		}
	},
	_elm_lang$core$Json_Decode$bool);
var _elm_lang$html$Html_Events$targetValue = A2(
	_elm_lang$core$Json_Decode$at,
	{
		ctor: '::',
		_0: 'target',
		_1: {
			ctor: '::',
			_0: 'value',
			_1: {ctor: '[]'}
		}
	},
	_elm_lang$core$Json_Decode$string);
var _elm_lang$html$Html_Events$defaultOptions = _elm_lang$virtual_dom$VirtualDom$defaultOptions;
var _elm_lang$html$Html_Events$onWithOptions = _elm_lang$virtual_dom$VirtualDom$onWithOptions;
var _elm_lang$html$Html_Events$on = _elm_lang$virtual_dom$VirtualDom$on;
var _elm_lang$html$Html_Events$onFocus = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'focus',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onBlur = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'blur',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onSubmitOptions = _elm_lang$core$Native_Utils.update(
	_elm_lang$html$Html_Events$defaultOptions,
	{preventDefault: true});
var _elm_lang$html$Html_Events$onSubmit = function (msg) {
	return A3(
		_elm_lang$html$Html_Events$onWithOptions,
		'submit',
		_elm_lang$html$Html_Events$onSubmitOptions,
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onCheck = function (tagger) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'change',
		A2(_elm_lang$core$Json_Decode$map, tagger, _elm_lang$html$Html_Events$targetChecked));
};
var _elm_lang$html$Html_Events$onInput = function (tagger) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'input',
		A2(_elm_lang$core$Json_Decode$map, tagger, _elm_lang$html$Html_Events$targetValue));
};
var _elm_lang$html$Html_Events$onMouseOut = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'mouseout',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onMouseOver = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'mouseover',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onMouseLeave = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'mouseleave',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onMouseEnter = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'mouseenter',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onMouseUp = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'mouseup',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onMouseDown = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'mousedown',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onDoubleClick = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'dblclick',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onClick = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'click',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$Options = F2(
	function (a, b) {
		return {stopPropagation: a, preventDefault: b};
	});

var _elm_lang$http$Native_Http = function() {


// ENCODING AND DECODING

function encodeUri(string)
{
	return encodeURIComponent(string);
}

function decodeUri(string)
{
	try
	{
		return _elm_lang$core$Maybe$Just(decodeURIComponent(string));
	}
	catch(e)
	{
		return _elm_lang$core$Maybe$Nothing;
	}
}


// SEND REQUEST

function toTask(request, maybeProgress)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		var xhr = new XMLHttpRequest();

		configureProgress(xhr, maybeProgress);

		xhr.addEventListener('error', function() {
			callback(_elm_lang$core$Native_Scheduler.fail({ ctor: 'NetworkError' }));
		});
		xhr.addEventListener('timeout', function() {
			callback(_elm_lang$core$Native_Scheduler.fail({ ctor: 'Timeout' }));
		});
		xhr.addEventListener('load', function() {
			callback(handleResponse(xhr, request.expect.responseToResult));
		});

		try
		{
			xhr.open(request.method, request.url, true);
		}
		catch (e)
		{
			return callback(_elm_lang$core$Native_Scheduler.fail({ ctor: 'BadUrl', _0: request.url }));
		}

		configureRequest(xhr, request);
		send(xhr, request.body);

		return function() { xhr.abort(); };
	});
}

function configureProgress(xhr, maybeProgress)
{
	if (maybeProgress.ctor === 'Nothing')
	{
		return;
	}

	xhr.addEventListener('progress', function(event) {
		if (!event.lengthComputable)
		{
			return;
		}
		_elm_lang$core$Native_Scheduler.rawSpawn(maybeProgress._0({
			bytes: event.loaded,
			bytesExpected: event.total
		}));
	});
}

function configureRequest(xhr, request)
{
	function setHeader(pair)
	{
		xhr.setRequestHeader(pair._0, pair._1);
	}

	A2(_elm_lang$core$List$map, setHeader, request.headers);
	xhr.responseType = request.expect.responseType;
	xhr.withCredentials = request.withCredentials;

	if (request.timeout.ctor === 'Just')
	{
		xhr.timeout = request.timeout._0;
	}
}

function send(xhr, body)
{
	switch (body.ctor)
	{
		case 'EmptyBody':
			xhr.send();
			return;

		case 'StringBody':
			xhr.setRequestHeader('Content-Type', body._0);
			xhr.send(body._1);
			return;

		case 'FormDataBody':
			xhr.send(body._0);
			return;
	}
}


// RESPONSES

function handleResponse(xhr, responseToResult)
{
	var response = toResponse(xhr);

	if (xhr.status < 200 || 300 <= xhr.status)
	{
		response.body = xhr.responseText;
		return _elm_lang$core$Native_Scheduler.fail({
			ctor: 'BadStatus',
			_0: response
		});
	}

	var result = responseToResult(response);

	if (result.ctor === 'Ok')
	{
		return _elm_lang$core$Native_Scheduler.succeed(result._0);
	}
	else
	{
		response.body = xhr.responseText;
		return _elm_lang$core$Native_Scheduler.fail({
			ctor: 'BadPayload',
			_0: result._0,
			_1: response
		});
	}
}

function toResponse(xhr)
{
	return {
		status: { code: xhr.status, message: xhr.statusText },
		headers: parseHeaders(xhr.getAllResponseHeaders()),
		url: xhr.responseURL,
		body: xhr.response
	};
}

function parseHeaders(rawHeaders)
{
	var headers = _elm_lang$core$Dict$empty;

	if (!rawHeaders)
	{
		return headers;
	}

	var headerPairs = rawHeaders.split('\u000d\u000a');
	for (var i = headerPairs.length; i--; )
	{
		var headerPair = headerPairs[i];
		var index = headerPair.indexOf('\u003a\u0020');
		if (index > 0)
		{
			var key = headerPair.substring(0, index);
			var value = headerPair.substring(index + 2);

			headers = A3(_elm_lang$core$Dict$update, key, function(oldValue) {
				if (oldValue.ctor === 'Just')
				{
					return _elm_lang$core$Maybe$Just(value + ', ' + oldValue._0);
				}
				return _elm_lang$core$Maybe$Just(value);
			}, headers);
		}
	}

	return headers;
}


// EXPECTORS

function expectStringResponse(responseToResult)
{
	return {
		responseType: 'text',
		responseToResult: responseToResult
	};
}

function mapExpect(func, expect)
{
	return {
		responseType: expect.responseType,
		responseToResult: function(response) {
			var convertedResponse = expect.responseToResult(response);
			return A2(_elm_lang$core$Result$map, func, convertedResponse);
		}
	};
}


// BODY

function multipart(parts)
{
	var formData = new FormData();

	while (parts.ctor !== '[]')
	{
		var part = parts._0;
		formData.append(part._0, part._1);
		parts = parts._1;
	}

	return { ctor: 'FormDataBody', _0: formData };
}

return {
	toTask: F2(toTask),
	expectStringResponse: expectStringResponse,
	mapExpect: F2(mapExpect),
	multipart: multipart,
	encodeUri: encodeUri,
	decodeUri: decodeUri
};

}();

var _elm_lang$http$Http_Internal$map = F2(
	function (func, request) {
		return _elm_lang$core$Native_Utils.update(
			request,
			{
				expect: A2(_elm_lang$http$Native_Http.mapExpect, func, request.expect)
			});
	});
var _elm_lang$http$Http_Internal$RawRequest = F7(
	function (a, b, c, d, e, f, g) {
		return {method: a, headers: b, url: c, body: d, expect: e, timeout: f, withCredentials: g};
	});
var _elm_lang$http$Http_Internal$Request = function (a) {
	return {ctor: 'Request', _0: a};
};
var _elm_lang$http$Http_Internal$Expect = {ctor: 'Expect'};
var _elm_lang$http$Http_Internal$FormDataBody = {ctor: 'FormDataBody'};
var _elm_lang$http$Http_Internal$StringBody = F2(
	function (a, b) {
		return {ctor: 'StringBody', _0: a, _1: b};
	});
var _elm_lang$http$Http_Internal$EmptyBody = {ctor: 'EmptyBody'};
var _elm_lang$http$Http_Internal$Header = F2(
	function (a, b) {
		return {ctor: 'Header', _0: a, _1: b};
	});

var _elm_lang$http$Http$decodeUri = _elm_lang$http$Native_Http.decodeUri;
var _elm_lang$http$Http$encodeUri = _elm_lang$http$Native_Http.encodeUri;
var _elm_lang$http$Http$expectStringResponse = _elm_lang$http$Native_Http.expectStringResponse;
var _elm_lang$http$Http$expectJson = function (decoder) {
	return _elm_lang$http$Http$expectStringResponse(
		function (response) {
			return A2(_elm_lang$core$Json_Decode$decodeString, decoder, response.body);
		});
};
var _elm_lang$http$Http$expectString = _elm_lang$http$Http$expectStringResponse(
	function (response) {
		return _elm_lang$core$Result$Ok(response.body);
	});
var _elm_lang$http$Http$multipartBody = _elm_lang$http$Native_Http.multipart;
var _elm_lang$http$Http$stringBody = _elm_lang$http$Http_Internal$StringBody;
var _elm_lang$http$Http$jsonBody = function (value) {
	return A2(
		_elm_lang$http$Http_Internal$StringBody,
		'application/json',
		A2(_elm_lang$core$Json_Encode$encode, 0, value));
};
var _elm_lang$http$Http$emptyBody = _elm_lang$http$Http_Internal$EmptyBody;
var _elm_lang$http$Http$header = _elm_lang$http$Http_Internal$Header;
var _elm_lang$http$Http$request = _elm_lang$http$Http_Internal$Request;
var _elm_lang$http$Http$post = F3(
	function (url, body, decoder) {
		return _elm_lang$http$Http$request(
			{
				method: 'POST',
				headers: {ctor: '[]'},
				url: url,
				body: body,
				expect: _elm_lang$http$Http$expectJson(decoder),
				timeout: _elm_lang$core$Maybe$Nothing,
				withCredentials: false
			});
	});
var _elm_lang$http$Http$get = F2(
	function (url, decoder) {
		return _elm_lang$http$Http$request(
			{
				method: 'GET',
				headers: {ctor: '[]'},
				url: url,
				body: _elm_lang$http$Http$emptyBody,
				expect: _elm_lang$http$Http$expectJson(decoder),
				timeout: _elm_lang$core$Maybe$Nothing,
				withCredentials: false
			});
	});
var _elm_lang$http$Http$getString = function (url) {
	return _elm_lang$http$Http$request(
		{
			method: 'GET',
			headers: {ctor: '[]'},
			url: url,
			body: _elm_lang$http$Http$emptyBody,
			expect: _elm_lang$http$Http$expectString,
			timeout: _elm_lang$core$Maybe$Nothing,
			withCredentials: false
		});
};
var _elm_lang$http$Http$toTask = function (_p0) {
	var _p1 = _p0;
	return A2(_elm_lang$http$Native_Http.toTask, _p1._0, _elm_lang$core$Maybe$Nothing);
};
var _elm_lang$http$Http$send = F2(
	function (resultToMessage, request) {
		return A2(
			_elm_lang$core$Task$attempt,
			resultToMessage,
			_elm_lang$http$Http$toTask(request));
	});
var _elm_lang$http$Http$Response = F4(
	function (a, b, c, d) {
		return {url: a, status: b, headers: c, body: d};
	});
var _elm_lang$http$Http$BadPayload = F2(
	function (a, b) {
		return {ctor: 'BadPayload', _0: a, _1: b};
	});
var _elm_lang$http$Http$BadStatus = function (a) {
	return {ctor: 'BadStatus', _0: a};
};
var _elm_lang$http$Http$NetworkError = {ctor: 'NetworkError'};
var _elm_lang$http$Http$Timeout = {ctor: 'Timeout'};
var _elm_lang$http$Http$BadUrl = function (a) {
	return {ctor: 'BadUrl', _0: a};
};
var _elm_lang$http$Http$StringPart = F2(
	function (a, b) {
		return {ctor: 'StringPart', _0: a, _1: b};
	});
var _elm_lang$http$Http$stringPart = _elm_lang$http$Http$StringPart;

var _elm_lang$navigation$Native_Navigation = function() {

function go(n)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		if (n !== 0)
		{
			history.go(n);
		}
		callback(_elm_lang$core$Native_Scheduler.succeed(_elm_lang$core$Native_Utils.Tuple0));
	});
}

function pushState(url)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		history.pushState({}, '', url);
		callback(_elm_lang$core$Native_Scheduler.succeed(getLocation()));
	});
}

function replaceState(url)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		history.replaceState({}, '', url);
		callback(_elm_lang$core$Native_Scheduler.succeed(getLocation()));
	});
}

function getLocation()
{
	var location = document.location;

	return {
		href: location.href,
		host: location.host,
		hostname: location.hostname,
		protocol: location.protocol,
		origin: location.origin,
		port_: location.port,
		pathname: location.pathname,
		search: location.search,
		hash: location.hash,
		username: location.username,
		password: location.password
	};
}


return {
	go: go,
	pushState: pushState,
	replaceState: replaceState,
	getLocation: getLocation
};

}();

var _elm_lang$navigation$Navigation$replaceState = _elm_lang$navigation$Native_Navigation.replaceState;
var _elm_lang$navigation$Navigation$pushState = _elm_lang$navigation$Native_Navigation.pushState;
var _elm_lang$navigation$Navigation$go = _elm_lang$navigation$Native_Navigation.go;
var _elm_lang$navigation$Navigation$spawnPopState = function (router) {
	return _elm_lang$core$Process$spawn(
		A3(
			_elm_lang$dom$Dom_LowLevel$onWindow,
			'popstate',
			_elm_lang$core$Json_Decode$value,
			function (_p0) {
				return A2(
					_elm_lang$core$Platform$sendToSelf,
					router,
					_elm_lang$navigation$Native_Navigation.getLocation(
						{ctor: '_Tuple0'}));
			}));
};
var _elm_lang$navigation$Navigation_ops = _elm_lang$navigation$Navigation_ops || {};
_elm_lang$navigation$Navigation_ops['&>'] = F2(
	function (task1, task2) {
		return A2(
			_elm_lang$core$Task$andThen,
			function (_p1) {
				return task2;
			},
			task1);
	});
var _elm_lang$navigation$Navigation$notify = F3(
	function (router, subs, location) {
		var send = function (_p2) {
			var _p3 = _p2;
			return A2(
				_elm_lang$core$Platform$sendToApp,
				router,
				_p3._0(location));
		};
		return A2(
			_elm_lang$navigation$Navigation_ops['&>'],
			_elm_lang$core$Task$sequence(
				A2(_elm_lang$core$List$map, send, subs)),
			_elm_lang$core$Task$succeed(
				{ctor: '_Tuple0'}));
	});
var _elm_lang$navigation$Navigation$onSelfMsg = F3(
	function (router, location, state) {
		return A2(
			_elm_lang$navigation$Navigation_ops['&>'],
			A3(_elm_lang$navigation$Navigation$notify, router, state.subs, location),
			_elm_lang$core$Task$succeed(state));
	});
var _elm_lang$navigation$Navigation$cmdHelp = F3(
	function (router, subs, cmd) {
		var _p4 = cmd;
		switch (_p4.ctor) {
			case 'Jump':
				return _elm_lang$navigation$Navigation$go(_p4._0);
			case 'New':
				return A2(
					_elm_lang$core$Task$andThen,
					A2(_elm_lang$navigation$Navigation$notify, router, subs),
					_elm_lang$navigation$Navigation$pushState(_p4._0));
			default:
				return A2(
					_elm_lang$core$Task$andThen,
					A2(_elm_lang$navigation$Navigation$notify, router, subs),
					_elm_lang$navigation$Navigation$replaceState(_p4._0));
		}
	});
var _elm_lang$navigation$Navigation$subscription = _elm_lang$core$Native_Platform.leaf('Navigation');
var _elm_lang$navigation$Navigation$command = _elm_lang$core$Native_Platform.leaf('Navigation');
var _elm_lang$navigation$Navigation$Location = function (a) {
	return function (b) {
		return function (c) {
			return function (d) {
				return function (e) {
					return function (f) {
						return function (g) {
							return function (h) {
								return function (i) {
									return function (j) {
										return function (k) {
											return {href: a, host: b, hostname: c, protocol: d, origin: e, port_: f, pathname: g, search: h, hash: i, username: j, password: k};
										};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};
var _elm_lang$navigation$Navigation$State = F2(
	function (a, b) {
		return {subs: a, process: b};
	});
var _elm_lang$navigation$Navigation$init = _elm_lang$core$Task$succeed(
	A2(
		_elm_lang$navigation$Navigation$State,
		{ctor: '[]'},
		_elm_lang$core$Maybe$Nothing));
var _elm_lang$navigation$Navigation$onEffects = F4(
	function (router, cmds, subs, _p5) {
		var _p6 = _p5;
		var _p9 = _p6.process;
		var stepState = function () {
			var _p7 = {ctor: '_Tuple2', _0: subs, _1: _p9};
			_v3_2:
			do {
				if (_p7._0.ctor === '[]') {
					if (_p7._1.ctor === 'Just') {
						return A2(
							_elm_lang$navigation$Navigation_ops['&>'],
							_elm_lang$core$Process$kill(_p7._1._0),
							_elm_lang$core$Task$succeed(
								A2(_elm_lang$navigation$Navigation$State, subs, _elm_lang$core$Maybe$Nothing)));
					} else {
						break _v3_2;
					}
				} else {
					if (_p7._1.ctor === 'Nothing') {
						return A2(
							_elm_lang$core$Task$map,
							function (_p8) {
								return A2(
									_elm_lang$navigation$Navigation$State,
									subs,
									_elm_lang$core$Maybe$Just(_p8));
							},
							_elm_lang$navigation$Navigation$spawnPopState(router));
					} else {
						break _v3_2;
					}
				}
			} while(false);
			return _elm_lang$core$Task$succeed(
				A2(_elm_lang$navigation$Navigation$State, subs, _p9));
		}();
		return A2(
			_elm_lang$navigation$Navigation_ops['&>'],
			_elm_lang$core$Task$sequence(
				A2(
					_elm_lang$core$List$map,
					A2(_elm_lang$navigation$Navigation$cmdHelp, router, subs),
					cmds)),
			stepState);
	});
var _elm_lang$navigation$Navigation$Modify = function (a) {
	return {ctor: 'Modify', _0: a};
};
var _elm_lang$navigation$Navigation$modifyUrl = function (url) {
	return _elm_lang$navigation$Navigation$command(
		_elm_lang$navigation$Navigation$Modify(url));
};
var _elm_lang$navigation$Navigation$New = function (a) {
	return {ctor: 'New', _0: a};
};
var _elm_lang$navigation$Navigation$newUrl = function (url) {
	return _elm_lang$navigation$Navigation$command(
		_elm_lang$navigation$Navigation$New(url));
};
var _elm_lang$navigation$Navigation$Jump = function (a) {
	return {ctor: 'Jump', _0: a};
};
var _elm_lang$navigation$Navigation$back = function (n) {
	return _elm_lang$navigation$Navigation$command(
		_elm_lang$navigation$Navigation$Jump(0 - n));
};
var _elm_lang$navigation$Navigation$forward = function (n) {
	return _elm_lang$navigation$Navigation$command(
		_elm_lang$navigation$Navigation$Jump(n));
};
var _elm_lang$navigation$Navigation$cmdMap = F2(
	function (_p10, myCmd) {
		var _p11 = myCmd;
		switch (_p11.ctor) {
			case 'Jump':
				return _elm_lang$navigation$Navigation$Jump(_p11._0);
			case 'New':
				return _elm_lang$navigation$Navigation$New(_p11._0);
			default:
				return _elm_lang$navigation$Navigation$Modify(_p11._0);
		}
	});
var _elm_lang$navigation$Navigation$Monitor = function (a) {
	return {ctor: 'Monitor', _0: a};
};
var _elm_lang$navigation$Navigation$program = F2(
	function (locationToMessage, stuff) {
		var init = stuff.init(
			_elm_lang$navigation$Native_Navigation.getLocation(
				{ctor: '_Tuple0'}));
		var subs = function (model) {
			return _elm_lang$core$Platform_Sub$batch(
				{
					ctor: '::',
					_0: _elm_lang$navigation$Navigation$subscription(
						_elm_lang$navigation$Navigation$Monitor(locationToMessage)),
					_1: {
						ctor: '::',
						_0: stuff.subscriptions(model),
						_1: {ctor: '[]'}
					}
				});
		};
		return _elm_lang$html$Html$program(
			{init: init, view: stuff.view, update: stuff.update, subscriptions: subs});
	});
var _elm_lang$navigation$Navigation$programWithFlags = F2(
	function (locationToMessage, stuff) {
		var init = function (flags) {
			return A2(
				stuff.init,
				flags,
				_elm_lang$navigation$Native_Navigation.getLocation(
					{ctor: '_Tuple0'}));
		};
		var subs = function (model) {
			return _elm_lang$core$Platform_Sub$batch(
				{
					ctor: '::',
					_0: _elm_lang$navigation$Navigation$subscription(
						_elm_lang$navigation$Navigation$Monitor(locationToMessage)),
					_1: {
						ctor: '::',
						_0: stuff.subscriptions(model),
						_1: {ctor: '[]'}
					}
				});
		};
		return _elm_lang$html$Html$programWithFlags(
			{init: init, view: stuff.view, update: stuff.update, subscriptions: subs});
	});
var _elm_lang$navigation$Navigation$subMap = F2(
	function (func, _p12) {
		var _p13 = _p12;
		return _elm_lang$navigation$Navigation$Monitor(
			function (_p14) {
				return func(
					_p13._0(_p14));
			});
	});
_elm_lang$core$Native_Platform.effectManagers['Navigation'] = {pkg: 'elm-lang/navigation', init: _elm_lang$navigation$Navigation$init, onEffects: _elm_lang$navigation$Navigation$onEffects, onSelfMsg: _elm_lang$navigation$Navigation$onSelfMsg, tag: 'fx', cmdMap: _elm_lang$navigation$Navigation$cmdMap, subMap: _elm_lang$navigation$Navigation$subMap};

var _elm_lang$svg$Svg$map = _elm_lang$virtual_dom$VirtualDom$map;
var _elm_lang$svg$Svg$text = _elm_lang$virtual_dom$VirtualDom$text;
var _elm_lang$svg$Svg$svgNamespace = A2(
	_elm_lang$virtual_dom$VirtualDom$property,
	'namespace',
	_elm_lang$core$Json_Encode$string('http://www.w3.org/2000/svg'));
var _elm_lang$svg$Svg$node = F3(
	function (name, attributes, children) {
		return A3(
			_elm_lang$virtual_dom$VirtualDom$node,
			name,
			{ctor: '::', _0: _elm_lang$svg$Svg$svgNamespace, _1: attributes},
			children);
	});
var _elm_lang$svg$Svg$svg = _elm_lang$svg$Svg$node('svg');
var _elm_lang$svg$Svg$foreignObject = _elm_lang$svg$Svg$node('foreignObject');
var _elm_lang$svg$Svg$animate = _elm_lang$svg$Svg$node('animate');
var _elm_lang$svg$Svg$animateColor = _elm_lang$svg$Svg$node('animateColor');
var _elm_lang$svg$Svg$animateMotion = _elm_lang$svg$Svg$node('animateMotion');
var _elm_lang$svg$Svg$animateTransform = _elm_lang$svg$Svg$node('animateTransform');
var _elm_lang$svg$Svg$mpath = _elm_lang$svg$Svg$node('mpath');
var _elm_lang$svg$Svg$set = _elm_lang$svg$Svg$node('set');
var _elm_lang$svg$Svg$a = _elm_lang$svg$Svg$node('a');
var _elm_lang$svg$Svg$defs = _elm_lang$svg$Svg$node('defs');
var _elm_lang$svg$Svg$g = _elm_lang$svg$Svg$node('g');
var _elm_lang$svg$Svg$marker = _elm_lang$svg$Svg$node('marker');
var _elm_lang$svg$Svg$mask = _elm_lang$svg$Svg$node('mask');
var _elm_lang$svg$Svg$pattern = _elm_lang$svg$Svg$node('pattern');
var _elm_lang$svg$Svg$switch = _elm_lang$svg$Svg$node('switch');
var _elm_lang$svg$Svg$symbol = _elm_lang$svg$Svg$node('symbol');
var _elm_lang$svg$Svg$desc = _elm_lang$svg$Svg$node('desc');
var _elm_lang$svg$Svg$metadata = _elm_lang$svg$Svg$node('metadata');
var _elm_lang$svg$Svg$title = _elm_lang$svg$Svg$node('title');
var _elm_lang$svg$Svg$feBlend = _elm_lang$svg$Svg$node('feBlend');
var _elm_lang$svg$Svg$feColorMatrix = _elm_lang$svg$Svg$node('feColorMatrix');
var _elm_lang$svg$Svg$feComponentTransfer = _elm_lang$svg$Svg$node('feComponentTransfer');
var _elm_lang$svg$Svg$feComposite = _elm_lang$svg$Svg$node('feComposite');
var _elm_lang$svg$Svg$feConvolveMatrix = _elm_lang$svg$Svg$node('feConvolveMatrix');
var _elm_lang$svg$Svg$feDiffuseLighting = _elm_lang$svg$Svg$node('feDiffuseLighting');
var _elm_lang$svg$Svg$feDisplacementMap = _elm_lang$svg$Svg$node('feDisplacementMap');
var _elm_lang$svg$Svg$feFlood = _elm_lang$svg$Svg$node('feFlood');
var _elm_lang$svg$Svg$feFuncA = _elm_lang$svg$Svg$node('feFuncA');
var _elm_lang$svg$Svg$feFuncB = _elm_lang$svg$Svg$node('feFuncB');
var _elm_lang$svg$Svg$feFuncG = _elm_lang$svg$Svg$node('feFuncG');
var _elm_lang$svg$Svg$feFuncR = _elm_lang$svg$Svg$node('feFuncR');
var _elm_lang$svg$Svg$feGaussianBlur = _elm_lang$svg$Svg$node('feGaussianBlur');
var _elm_lang$svg$Svg$feImage = _elm_lang$svg$Svg$node('feImage');
var _elm_lang$svg$Svg$feMerge = _elm_lang$svg$Svg$node('feMerge');
var _elm_lang$svg$Svg$feMergeNode = _elm_lang$svg$Svg$node('feMergeNode');
var _elm_lang$svg$Svg$feMorphology = _elm_lang$svg$Svg$node('feMorphology');
var _elm_lang$svg$Svg$feOffset = _elm_lang$svg$Svg$node('feOffset');
var _elm_lang$svg$Svg$feSpecularLighting = _elm_lang$svg$Svg$node('feSpecularLighting');
var _elm_lang$svg$Svg$feTile = _elm_lang$svg$Svg$node('feTile');
var _elm_lang$svg$Svg$feTurbulence = _elm_lang$svg$Svg$node('feTurbulence');
var _elm_lang$svg$Svg$font = _elm_lang$svg$Svg$node('font');
var _elm_lang$svg$Svg$linearGradient = _elm_lang$svg$Svg$node('linearGradient');
var _elm_lang$svg$Svg$radialGradient = _elm_lang$svg$Svg$node('radialGradient');
var _elm_lang$svg$Svg$stop = _elm_lang$svg$Svg$node('stop');
var _elm_lang$svg$Svg$circle = _elm_lang$svg$Svg$node('circle');
var _elm_lang$svg$Svg$ellipse = _elm_lang$svg$Svg$node('ellipse');
var _elm_lang$svg$Svg$image = _elm_lang$svg$Svg$node('image');
var _elm_lang$svg$Svg$line = _elm_lang$svg$Svg$node('line');
var _elm_lang$svg$Svg$path = _elm_lang$svg$Svg$node('path');
var _elm_lang$svg$Svg$polygon = _elm_lang$svg$Svg$node('polygon');
var _elm_lang$svg$Svg$polyline = _elm_lang$svg$Svg$node('polyline');
var _elm_lang$svg$Svg$rect = _elm_lang$svg$Svg$node('rect');
var _elm_lang$svg$Svg$use = _elm_lang$svg$Svg$node('use');
var _elm_lang$svg$Svg$feDistantLight = _elm_lang$svg$Svg$node('feDistantLight');
var _elm_lang$svg$Svg$fePointLight = _elm_lang$svg$Svg$node('fePointLight');
var _elm_lang$svg$Svg$feSpotLight = _elm_lang$svg$Svg$node('feSpotLight');
var _elm_lang$svg$Svg$altGlyph = _elm_lang$svg$Svg$node('altGlyph');
var _elm_lang$svg$Svg$altGlyphDef = _elm_lang$svg$Svg$node('altGlyphDef');
var _elm_lang$svg$Svg$altGlyphItem = _elm_lang$svg$Svg$node('altGlyphItem');
var _elm_lang$svg$Svg$glyph = _elm_lang$svg$Svg$node('glyph');
var _elm_lang$svg$Svg$glyphRef = _elm_lang$svg$Svg$node('glyphRef');
var _elm_lang$svg$Svg$textPath = _elm_lang$svg$Svg$node('textPath');
var _elm_lang$svg$Svg$text_ = _elm_lang$svg$Svg$node('text');
var _elm_lang$svg$Svg$tref = _elm_lang$svg$Svg$node('tref');
var _elm_lang$svg$Svg$tspan = _elm_lang$svg$Svg$node('tspan');
var _elm_lang$svg$Svg$clipPath = _elm_lang$svg$Svg$node('clipPath');
var _elm_lang$svg$Svg$colorProfile = _elm_lang$svg$Svg$node('colorProfile');
var _elm_lang$svg$Svg$cursor = _elm_lang$svg$Svg$node('cursor');
var _elm_lang$svg$Svg$filter = _elm_lang$svg$Svg$node('filter');
var _elm_lang$svg$Svg$script = _elm_lang$svg$Svg$node('script');
var _elm_lang$svg$Svg$style = _elm_lang$svg$Svg$node('style');
var _elm_lang$svg$Svg$view = _elm_lang$svg$Svg$node('view');

var _elm_lang$svg$Svg_Attributes$writingMode = _elm_lang$virtual_dom$VirtualDom$attribute('writing-mode');
var _elm_lang$svg$Svg_Attributes$wordSpacing = _elm_lang$virtual_dom$VirtualDom$attribute('word-spacing');
var _elm_lang$svg$Svg_Attributes$visibility = _elm_lang$virtual_dom$VirtualDom$attribute('visibility');
var _elm_lang$svg$Svg_Attributes$unicodeBidi = _elm_lang$virtual_dom$VirtualDom$attribute('unicode-bidi');
var _elm_lang$svg$Svg_Attributes$textRendering = _elm_lang$virtual_dom$VirtualDom$attribute('text-rendering');
var _elm_lang$svg$Svg_Attributes$textDecoration = _elm_lang$virtual_dom$VirtualDom$attribute('text-decoration');
var _elm_lang$svg$Svg_Attributes$textAnchor = _elm_lang$virtual_dom$VirtualDom$attribute('text-anchor');
var _elm_lang$svg$Svg_Attributes$stroke = _elm_lang$virtual_dom$VirtualDom$attribute('stroke');
var _elm_lang$svg$Svg_Attributes$strokeWidth = _elm_lang$virtual_dom$VirtualDom$attribute('stroke-width');
var _elm_lang$svg$Svg_Attributes$strokeOpacity = _elm_lang$virtual_dom$VirtualDom$attribute('stroke-opacity');
var _elm_lang$svg$Svg_Attributes$strokeMiterlimit = _elm_lang$virtual_dom$VirtualDom$attribute('stroke-miterlimit');
var _elm_lang$svg$Svg_Attributes$strokeLinejoin = _elm_lang$virtual_dom$VirtualDom$attribute('stroke-linejoin');
var _elm_lang$svg$Svg_Attributes$strokeLinecap = _elm_lang$virtual_dom$VirtualDom$attribute('stroke-linecap');
var _elm_lang$svg$Svg_Attributes$strokeDashoffset = _elm_lang$virtual_dom$VirtualDom$attribute('stroke-dashoffset');
var _elm_lang$svg$Svg_Attributes$strokeDasharray = _elm_lang$virtual_dom$VirtualDom$attribute('stroke-dasharray');
var _elm_lang$svg$Svg_Attributes$stopOpacity = _elm_lang$virtual_dom$VirtualDom$attribute('stop-opacity');
var _elm_lang$svg$Svg_Attributes$stopColor = _elm_lang$virtual_dom$VirtualDom$attribute('stop-color');
var _elm_lang$svg$Svg_Attributes$shapeRendering = _elm_lang$virtual_dom$VirtualDom$attribute('shape-rendering');
var _elm_lang$svg$Svg_Attributes$pointerEvents = _elm_lang$virtual_dom$VirtualDom$attribute('pointer-events');
var _elm_lang$svg$Svg_Attributes$overflow = _elm_lang$virtual_dom$VirtualDom$attribute('overflow');
var _elm_lang$svg$Svg_Attributes$opacity = _elm_lang$virtual_dom$VirtualDom$attribute('opacity');
var _elm_lang$svg$Svg_Attributes$mask = _elm_lang$virtual_dom$VirtualDom$attribute('mask');
var _elm_lang$svg$Svg_Attributes$markerStart = _elm_lang$virtual_dom$VirtualDom$attribute('marker-start');
var _elm_lang$svg$Svg_Attributes$markerMid = _elm_lang$virtual_dom$VirtualDom$attribute('marker-mid');
var _elm_lang$svg$Svg_Attributes$markerEnd = _elm_lang$virtual_dom$VirtualDom$attribute('marker-end');
var _elm_lang$svg$Svg_Attributes$lightingColor = _elm_lang$virtual_dom$VirtualDom$attribute('lighting-color');
var _elm_lang$svg$Svg_Attributes$letterSpacing = _elm_lang$virtual_dom$VirtualDom$attribute('letter-spacing');
var _elm_lang$svg$Svg_Attributes$kerning = _elm_lang$virtual_dom$VirtualDom$attribute('kerning');
var _elm_lang$svg$Svg_Attributes$imageRendering = _elm_lang$virtual_dom$VirtualDom$attribute('image-rendering');
var _elm_lang$svg$Svg_Attributes$glyphOrientationVertical = _elm_lang$virtual_dom$VirtualDom$attribute('glyph-orientation-vertical');
var _elm_lang$svg$Svg_Attributes$glyphOrientationHorizontal = _elm_lang$virtual_dom$VirtualDom$attribute('glyph-orientation-horizontal');
var _elm_lang$svg$Svg_Attributes$fontWeight = _elm_lang$virtual_dom$VirtualDom$attribute('font-weight');
var _elm_lang$svg$Svg_Attributes$fontVariant = _elm_lang$virtual_dom$VirtualDom$attribute('font-variant');
var _elm_lang$svg$Svg_Attributes$fontStyle = _elm_lang$virtual_dom$VirtualDom$attribute('font-style');
var _elm_lang$svg$Svg_Attributes$fontStretch = _elm_lang$virtual_dom$VirtualDom$attribute('font-stretch');
var _elm_lang$svg$Svg_Attributes$fontSize = _elm_lang$virtual_dom$VirtualDom$attribute('font-size');
var _elm_lang$svg$Svg_Attributes$fontSizeAdjust = _elm_lang$virtual_dom$VirtualDom$attribute('font-size-adjust');
var _elm_lang$svg$Svg_Attributes$fontFamily = _elm_lang$virtual_dom$VirtualDom$attribute('font-family');
var _elm_lang$svg$Svg_Attributes$floodOpacity = _elm_lang$virtual_dom$VirtualDom$attribute('flood-opacity');
var _elm_lang$svg$Svg_Attributes$floodColor = _elm_lang$virtual_dom$VirtualDom$attribute('flood-color');
var _elm_lang$svg$Svg_Attributes$filter = _elm_lang$virtual_dom$VirtualDom$attribute('filter');
var _elm_lang$svg$Svg_Attributes$fill = _elm_lang$virtual_dom$VirtualDom$attribute('fill');
var _elm_lang$svg$Svg_Attributes$fillRule = _elm_lang$virtual_dom$VirtualDom$attribute('fill-rule');
var _elm_lang$svg$Svg_Attributes$fillOpacity = _elm_lang$virtual_dom$VirtualDom$attribute('fill-opacity');
var _elm_lang$svg$Svg_Attributes$enableBackground = _elm_lang$virtual_dom$VirtualDom$attribute('enable-background');
var _elm_lang$svg$Svg_Attributes$dominantBaseline = _elm_lang$virtual_dom$VirtualDom$attribute('dominant-baseline');
var _elm_lang$svg$Svg_Attributes$display = _elm_lang$virtual_dom$VirtualDom$attribute('display');
var _elm_lang$svg$Svg_Attributes$direction = _elm_lang$virtual_dom$VirtualDom$attribute('direction');
var _elm_lang$svg$Svg_Attributes$cursor = _elm_lang$virtual_dom$VirtualDom$attribute('cursor');
var _elm_lang$svg$Svg_Attributes$color = _elm_lang$virtual_dom$VirtualDom$attribute('color');
var _elm_lang$svg$Svg_Attributes$colorRendering = _elm_lang$virtual_dom$VirtualDom$attribute('color-rendering');
var _elm_lang$svg$Svg_Attributes$colorProfile = _elm_lang$virtual_dom$VirtualDom$attribute('color-profile');
var _elm_lang$svg$Svg_Attributes$colorInterpolation = _elm_lang$virtual_dom$VirtualDom$attribute('color-interpolation');
var _elm_lang$svg$Svg_Attributes$colorInterpolationFilters = _elm_lang$virtual_dom$VirtualDom$attribute('color-interpolation-filters');
var _elm_lang$svg$Svg_Attributes$clip = _elm_lang$virtual_dom$VirtualDom$attribute('clip');
var _elm_lang$svg$Svg_Attributes$clipRule = _elm_lang$virtual_dom$VirtualDom$attribute('clip-rule');
var _elm_lang$svg$Svg_Attributes$clipPath = _elm_lang$virtual_dom$VirtualDom$attribute('clip-path');
var _elm_lang$svg$Svg_Attributes$baselineShift = _elm_lang$virtual_dom$VirtualDom$attribute('baseline-shift');
var _elm_lang$svg$Svg_Attributes$alignmentBaseline = _elm_lang$virtual_dom$VirtualDom$attribute('alignment-baseline');
var _elm_lang$svg$Svg_Attributes$zoomAndPan = _elm_lang$virtual_dom$VirtualDom$attribute('zoomAndPan');
var _elm_lang$svg$Svg_Attributes$z = _elm_lang$virtual_dom$VirtualDom$attribute('z');
var _elm_lang$svg$Svg_Attributes$yChannelSelector = _elm_lang$virtual_dom$VirtualDom$attribute('yChannelSelector');
var _elm_lang$svg$Svg_Attributes$y2 = _elm_lang$virtual_dom$VirtualDom$attribute('y2');
var _elm_lang$svg$Svg_Attributes$y1 = _elm_lang$virtual_dom$VirtualDom$attribute('y1');
var _elm_lang$svg$Svg_Attributes$y = _elm_lang$virtual_dom$VirtualDom$attribute('y');
var _elm_lang$svg$Svg_Attributes$xmlSpace = A2(_elm_lang$virtual_dom$VirtualDom$attributeNS, 'http://www.w3.org/XML/1998/namespace', 'xml:space');
var _elm_lang$svg$Svg_Attributes$xmlLang = A2(_elm_lang$virtual_dom$VirtualDom$attributeNS, 'http://www.w3.org/XML/1998/namespace', 'xml:lang');
var _elm_lang$svg$Svg_Attributes$xmlBase = A2(_elm_lang$virtual_dom$VirtualDom$attributeNS, 'http://www.w3.org/XML/1998/namespace', 'xml:base');
var _elm_lang$svg$Svg_Attributes$xlinkType = A2(_elm_lang$virtual_dom$VirtualDom$attributeNS, 'http://www.w3.org/1999/xlink', 'xlink:type');
var _elm_lang$svg$Svg_Attributes$xlinkTitle = A2(_elm_lang$virtual_dom$VirtualDom$attributeNS, 'http://www.w3.org/1999/xlink', 'xlink:title');
var _elm_lang$svg$Svg_Attributes$xlinkShow = A2(_elm_lang$virtual_dom$VirtualDom$attributeNS, 'http://www.w3.org/1999/xlink', 'xlink:show');
var _elm_lang$svg$Svg_Attributes$xlinkRole = A2(_elm_lang$virtual_dom$VirtualDom$attributeNS, 'http://www.w3.org/1999/xlink', 'xlink:role');
var _elm_lang$svg$Svg_Attributes$xlinkHref = A2(_elm_lang$virtual_dom$VirtualDom$attributeNS, 'http://www.w3.org/1999/xlink', 'xlink:href');
var _elm_lang$svg$Svg_Attributes$xlinkArcrole = A2(_elm_lang$virtual_dom$VirtualDom$attributeNS, 'http://www.w3.org/1999/xlink', 'xlink:arcrole');
var _elm_lang$svg$Svg_Attributes$xlinkActuate = A2(_elm_lang$virtual_dom$VirtualDom$attributeNS, 'http://www.w3.org/1999/xlink', 'xlink:actuate');
var _elm_lang$svg$Svg_Attributes$xChannelSelector = _elm_lang$virtual_dom$VirtualDom$attribute('xChannelSelector');
var _elm_lang$svg$Svg_Attributes$x2 = _elm_lang$virtual_dom$VirtualDom$attribute('x2');
var _elm_lang$svg$Svg_Attributes$x1 = _elm_lang$virtual_dom$VirtualDom$attribute('x1');
var _elm_lang$svg$Svg_Attributes$xHeight = _elm_lang$virtual_dom$VirtualDom$attribute('x-height');
var _elm_lang$svg$Svg_Attributes$x = _elm_lang$virtual_dom$VirtualDom$attribute('x');
var _elm_lang$svg$Svg_Attributes$widths = _elm_lang$virtual_dom$VirtualDom$attribute('widths');
var _elm_lang$svg$Svg_Attributes$width = _elm_lang$virtual_dom$VirtualDom$attribute('width');
var _elm_lang$svg$Svg_Attributes$viewTarget = _elm_lang$virtual_dom$VirtualDom$attribute('viewTarget');
var _elm_lang$svg$Svg_Attributes$viewBox = _elm_lang$virtual_dom$VirtualDom$attribute('viewBox');
var _elm_lang$svg$Svg_Attributes$vertOriginY = _elm_lang$virtual_dom$VirtualDom$attribute('vert-origin-y');
var _elm_lang$svg$Svg_Attributes$vertOriginX = _elm_lang$virtual_dom$VirtualDom$attribute('vert-origin-x');
var _elm_lang$svg$Svg_Attributes$vertAdvY = _elm_lang$virtual_dom$VirtualDom$attribute('vert-adv-y');
var _elm_lang$svg$Svg_Attributes$version = _elm_lang$virtual_dom$VirtualDom$attribute('version');
var _elm_lang$svg$Svg_Attributes$values = _elm_lang$virtual_dom$VirtualDom$attribute('values');
var _elm_lang$svg$Svg_Attributes$vMathematical = _elm_lang$virtual_dom$VirtualDom$attribute('v-mathematical');
var _elm_lang$svg$Svg_Attributes$vIdeographic = _elm_lang$virtual_dom$VirtualDom$attribute('v-ideographic');
var _elm_lang$svg$Svg_Attributes$vHanging = _elm_lang$virtual_dom$VirtualDom$attribute('v-hanging');
var _elm_lang$svg$Svg_Attributes$vAlphabetic = _elm_lang$virtual_dom$VirtualDom$attribute('v-alphabetic');
var _elm_lang$svg$Svg_Attributes$unitsPerEm = _elm_lang$virtual_dom$VirtualDom$attribute('units-per-em');
var _elm_lang$svg$Svg_Attributes$unicodeRange = _elm_lang$virtual_dom$VirtualDom$attribute('unicode-range');
var _elm_lang$svg$Svg_Attributes$unicode = _elm_lang$virtual_dom$VirtualDom$attribute('unicode');
var _elm_lang$svg$Svg_Attributes$underlineThickness = _elm_lang$virtual_dom$VirtualDom$attribute('underline-thickness');
var _elm_lang$svg$Svg_Attributes$underlinePosition = _elm_lang$virtual_dom$VirtualDom$attribute('underline-position');
var _elm_lang$svg$Svg_Attributes$u2 = _elm_lang$virtual_dom$VirtualDom$attribute('u2');
var _elm_lang$svg$Svg_Attributes$u1 = _elm_lang$virtual_dom$VirtualDom$attribute('u1');
var _elm_lang$svg$Svg_Attributes$type_ = _elm_lang$virtual_dom$VirtualDom$attribute('type');
var _elm_lang$svg$Svg_Attributes$transform = _elm_lang$virtual_dom$VirtualDom$attribute('transform');
var _elm_lang$svg$Svg_Attributes$to = _elm_lang$virtual_dom$VirtualDom$attribute('to');
var _elm_lang$svg$Svg_Attributes$title = _elm_lang$virtual_dom$VirtualDom$attribute('title');
var _elm_lang$svg$Svg_Attributes$textLength = _elm_lang$virtual_dom$VirtualDom$attribute('textLength');
var _elm_lang$svg$Svg_Attributes$targetY = _elm_lang$virtual_dom$VirtualDom$attribute('targetY');
var _elm_lang$svg$Svg_Attributes$targetX = _elm_lang$virtual_dom$VirtualDom$attribute('targetX');
var _elm_lang$svg$Svg_Attributes$target = _elm_lang$virtual_dom$VirtualDom$attribute('target');
var _elm_lang$svg$Svg_Attributes$tableValues = _elm_lang$virtual_dom$VirtualDom$attribute('tableValues');
var _elm_lang$svg$Svg_Attributes$systemLanguage = _elm_lang$virtual_dom$VirtualDom$attribute('systemLanguage');
var _elm_lang$svg$Svg_Attributes$surfaceScale = _elm_lang$virtual_dom$VirtualDom$attribute('surfaceScale');
var _elm_lang$svg$Svg_Attributes$style = _elm_lang$virtual_dom$VirtualDom$attribute('style');
var _elm_lang$svg$Svg_Attributes$string = _elm_lang$virtual_dom$VirtualDom$attribute('string');
var _elm_lang$svg$Svg_Attributes$strikethroughThickness = _elm_lang$virtual_dom$VirtualDom$attribute('strikethrough-thickness');
var _elm_lang$svg$Svg_Attributes$strikethroughPosition = _elm_lang$virtual_dom$VirtualDom$attribute('strikethrough-position');
var _elm_lang$svg$Svg_Attributes$stitchTiles = _elm_lang$virtual_dom$VirtualDom$attribute('stitchTiles');
var _elm_lang$svg$Svg_Attributes$stemv = _elm_lang$virtual_dom$VirtualDom$attribute('stemv');
var _elm_lang$svg$Svg_Attributes$stemh = _elm_lang$virtual_dom$VirtualDom$attribute('stemh');
var _elm_lang$svg$Svg_Attributes$stdDeviation = _elm_lang$virtual_dom$VirtualDom$attribute('stdDeviation');
var _elm_lang$svg$Svg_Attributes$startOffset = _elm_lang$virtual_dom$VirtualDom$attribute('startOffset');
var _elm_lang$svg$Svg_Attributes$spreadMethod = _elm_lang$virtual_dom$VirtualDom$attribute('spreadMethod');
var _elm_lang$svg$Svg_Attributes$speed = _elm_lang$virtual_dom$VirtualDom$attribute('speed');
var _elm_lang$svg$Svg_Attributes$specularExponent = _elm_lang$virtual_dom$VirtualDom$attribute('specularExponent');
var _elm_lang$svg$Svg_Attributes$specularConstant = _elm_lang$virtual_dom$VirtualDom$attribute('specularConstant');
var _elm_lang$svg$Svg_Attributes$spacing = _elm_lang$virtual_dom$VirtualDom$attribute('spacing');
var _elm_lang$svg$Svg_Attributes$slope = _elm_lang$virtual_dom$VirtualDom$attribute('slope');
var _elm_lang$svg$Svg_Attributes$seed = _elm_lang$virtual_dom$VirtualDom$attribute('seed');
var _elm_lang$svg$Svg_Attributes$scale = _elm_lang$virtual_dom$VirtualDom$attribute('scale');
var _elm_lang$svg$Svg_Attributes$ry = _elm_lang$virtual_dom$VirtualDom$attribute('ry');
var _elm_lang$svg$Svg_Attributes$rx = _elm_lang$virtual_dom$VirtualDom$attribute('rx');
var _elm_lang$svg$Svg_Attributes$rotate = _elm_lang$virtual_dom$VirtualDom$attribute('rotate');
var _elm_lang$svg$Svg_Attributes$result = _elm_lang$virtual_dom$VirtualDom$attribute('result');
var _elm_lang$svg$Svg_Attributes$restart = _elm_lang$virtual_dom$VirtualDom$attribute('restart');
var _elm_lang$svg$Svg_Attributes$requiredFeatures = _elm_lang$virtual_dom$VirtualDom$attribute('requiredFeatures');
var _elm_lang$svg$Svg_Attributes$requiredExtensions = _elm_lang$virtual_dom$VirtualDom$attribute('requiredExtensions');
var _elm_lang$svg$Svg_Attributes$repeatDur = _elm_lang$virtual_dom$VirtualDom$attribute('repeatDur');
var _elm_lang$svg$Svg_Attributes$repeatCount = _elm_lang$virtual_dom$VirtualDom$attribute('repeatCount');
var _elm_lang$svg$Svg_Attributes$renderingIntent = _elm_lang$virtual_dom$VirtualDom$attribute('rendering-intent');
var _elm_lang$svg$Svg_Attributes$refY = _elm_lang$virtual_dom$VirtualDom$attribute('refY');
var _elm_lang$svg$Svg_Attributes$refX = _elm_lang$virtual_dom$VirtualDom$attribute('refX');
var _elm_lang$svg$Svg_Attributes$radius = _elm_lang$virtual_dom$VirtualDom$attribute('radius');
var _elm_lang$svg$Svg_Attributes$r = _elm_lang$virtual_dom$VirtualDom$attribute('r');
var _elm_lang$svg$Svg_Attributes$primitiveUnits = _elm_lang$virtual_dom$VirtualDom$attribute('primitiveUnits');
var _elm_lang$svg$Svg_Attributes$preserveAspectRatio = _elm_lang$virtual_dom$VirtualDom$attribute('preserveAspectRatio');
var _elm_lang$svg$Svg_Attributes$preserveAlpha = _elm_lang$virtual_dom$VirtualDom$attribute('preserveAlpha');
var _elm_lang$svg$Svg_Attributes$pointsAtZ = _elm_lang$virtual_dom$VirtualDom$attribute('pointsAtZ');
var _elm_lang$svg$Svg_Attributes$pointsAtY = _elm_lang$virtual_dom$VirtualDom$attribute('pointsAtY');
var _elm_lang$svg$Svg_Attributes$pointsAtX = _elm_lang$virtual_dom$VirtualDom$attribute('pointsAtX');
var _elm_lang$svg$Svg_Attributes$points = _elm_lang$virtual_dom$VirtualDom$attribute('points');
var _elm_lang$svg$Svg_Attributes$pointOrder = _elm_lang$virtual_dom$VirtualDom$attribute('point-order');
var _elm_lang$svg$Svg_Attributes$patternUnits = _elm_lang$virtual_dom$VirtualDom$attribute('patternUnits');
var _elm_lang$svg$Svg_Attributes$patternTransform = _elm_lang$virtual_dom$VirtualDom$attribute('patternTransform');
var _elm_lang$svg$Svg_Attributes$patternContentUnits = _elm_lang$virtual_dom$VirtualDom$attribute('patternContentUnits');
var _elm_lang$svg$Svg_Attributes$pathLength = _elm_lang$virtual_dom$VirtualDom$attribute('pathLength');
var _elm_lang$svg$Svg_Attributes$path = _elm_lang$virtual_dom$VirtualDom$attribute('path');
var _elm_lang$svg$Svg_Attributes$panose1 = _elm_lang$virtual_dom$VirtualDom$attribute('panose-1');
var _elm_lang$svg$Svg_Attributes$overlineThickness = _elm_lang$virtual_dom$VirtualDom$attribute('overline-thickness');
var _elm_lang$svg$Svg_Attributes$overlinePosition = _elm_lang$virtual_dom$VirtualDom$attribute('overline-position');
var _elm_lang$svg$Svg_Attributes$origin = _elm_lang$virtual_dom$VirtualDom$attribute('origin');
var _elm_lang$svg$Svg_Attributes$orientation = _elm_lang$virtual_dom$VirtualDom$attribute('orientation');
var _elm_lang$svg$Svg_Attributes$orient = _elm_lang$virtual_dom$VirtualDom$attribute('orient');
var _elm_lang$svg$Svg_Attributes$order = _elm_lang$virtual_dom$VirtualDom$attribute('order');
var _elm_lang$svg$Svg_Attributes$operator = _elm_lang$virtual_dom$VirtualDom$attribute('operator');
var _elm_lang$svg$Svg_Attributes$offset = _elm_lang$virtual_dom$VirtualDom$attribute('offset');
var _elm_lang$svg$Svg_Attributes$numOctaves = _elm_lang$virtual_dom$VirtualDom$attribute('numOctaves');
var _elm_lang$svg$Svg_Attributes$name = _elm_lang$virtual_dom$VirtualDom$attribute('name');
var _elm_lang$svg$Svg_Attributes$mode = _elm_lang$virtual_dom$VirtualDom$attribute('mode');
var _elm_lang$svg$Svg_Attributes$min = _elm_lang$virtual_dom$VirtualDom$attribute('min');
var _elm_lang$svg$Svg_Attributes$method = _elm_lang$virtual_dom$VirtualDom$attribute('method');
var _elm_lang$svg$Svg_Attributes$media = _elm_lang$virtual_dom$VirtualDom$attribute('media');
var _elm_lang$svg$Svg_Attributes$max = _elm_lang$virtual_dom$VirtualDom$attribute('max');
var _elm_lang$svg$Svg_Attributes$mathematical = _elm_lang$virtual_dom$VirtualDom$attribute('mathematical');
var _elm_lang$svg$Svg_Attributes$maskUnits = _elm_lang$virtual_dom$VirtualDom$attribute('maskUnits');
var _elm_lang$svg$Svg_Attributes$maskContentUnits = _elm_lang$virtual_dom$VirtualDom$attribute('maskContentUnits');
var _elm_lang$svg$Svg_Attributes$markerWidth = _elm_lang$virtual_dom$VirtualDom$attribute('markerWidth');
var _elm_lang$svg$Svg_Attributes$markerUnits = _elm_lang$virtual_dom$VirtualDom$attribute('markerUnits');
var _elm_lang$svg$Svg_Attributes$markerHeight = _elm_lang$virtual_dom$VirtualDom$attribute('markerHeight');
var _elm_lang$svg$Svg_Attributes$local = _elm_lang$virtual_dom$VirtualDom$attribute('local');
var _elm_lang$svg$Svg_Attributes$limitingConeAngle = _elm_lang$virtual_dom$VirtualDom$attribute('limitingConeAngle');
var _elm_lang$svg$Svg_Attributes$lengthAdjust = _elm_lang$virtual_dom$VirtualDom$attribute('lengthAdjust');
var _elm_lang$svg$Svg_Attributes$lang = _elm_lang$virtual_dom$VirtualDom$attribute('lang');
var _elm_lang$svg$Svg_Attributes$keyTimes = _elm_lang$virtual_dom$VirtualDom$attribute('keyTimes');
var _elm_lang$svg$Svg_Attributes$keySplines = _elm_lang$virtual_dom$VirtualDom$attribute('keySplines');
var _elm_lang$svg$Svg_Attributes$keyPoints = _elm_lang$virtual_dom$VirtualDom$attribute('keyPoints');
var _elm_lang$svg$Svg_Attributes$kernelUnitLength = _elm_lang$virtual_dom$VirtualDom$attribute('kernelUnitLength');
var _elm_lang$svg$Svg_Attributes$kernelMatrix = _elm_lang$virtual_dom$VirtualDom$attribute('kernelMatrix');
var _elm_lang$svg$Svg_Attributes$k4 = _elm_lang$virtual_dom$VirtualDom$attribute('k4');
var _elm_lang$svg$Svg_Attributes$k3 = _elm_lang$virtual_dom$VirtualDom$attribute('k3');
var _elm_lang$svg$Svg_Attributes$k2 = _elm_lang$virtual_dom$VirtualDom$attribute('k2');
var _elm_lang$svg$Svg_Attributes$k1 = _elm_lang$virtual_dom$VirtualDom$attribute('k1');
var _elm_lang$svg$Svg_Attributes$k = _elm_lang$virtual_dom$VirtualDom$attribute('k');
var _elm_lang$svg$Svg_Attributes$intercept = _elm_lang$virtual_dom$VirtualDom$attribute('intercept');
var _elm_lang$svg$Svg_Attributes$in2 = _elm_lang$virtual_dom$VirtualDom$attribute('in2');
var _elm_lang$svg$Svg_Attributes$in_ = _elm_lang$virtual_dom$VirtualDom$attribute('in');
var _elm_lang$svg$Svg_Attributes$ideographic = _elm_lang$virtual_dom$VirtualDom$attribute('ideographic');
var _elm_lang$svg$Svg_Attributes$id = _elm_lang$virtual_dom$VirtualDom$attribute('id');
var _elm_lang$svg$Svg_Attributes$horizOriginY = _elm_lang$virtual_dom$VirtualDom$attribute('horiz-origin-y');
var _elm_lang$svg$Svg_Attributes$horizOriginX = _elm_lang$virtual_dom$VirtualDom$attribute('horiz-origin-x');
var _elm_lang$svg$Svg_Attributes$horizAdvX = _elm_lang$virtual_dom$VirtualDom$attribute('horiz-adv-x');
var _elm_lang$svg$Svg_Attributes$height = _elm_lang$virtual_dom$VirtualDom$attribute('height');
var _elm_lang$svg$Svg_Attributes$hanging = _elm_lang$virtual_dom$VirtualDom$attribute('hanging');
var _elm_lang$svg$Svg_Attributes$gradientUnits = _elm_lang$virtual_dom$VirtualDom$attribute('gradientUnits');
var _elm_lang$svg$Svg_Attributes$gradientTransform = _elm_lang$virtual_dom$VirtualDom$attribute('gradientTransform');
var _elm_lang$svg$Svg_Attributes$glyphRef = _elm_lang$virtual_dom$VirtualDom$attribute('glyphRef');
var _elm_lang$svg$Svg_Attributes$glyphName = _elm_lang$virtual_dom$VirtualDom$attribute('glyph-name');
var _elm_lang$svg$Svg_Attributes$g2 = _elm_lang$virtual_dom$VirtualDom$attribute('g2');
var _elm_lang$svg$Svg_Attributes$g1 = _elm_lang$virtual_dom$VirtualDom$attribute('g1');
var _elm_lang$svg$Svg_Attributes$fy = _elm_lang$virtual_dom$VirtualDom$attribute('fy');
var _elm_lang$svg$Svg_Attributes$fx = _elm_lang$virtual_dom$VirtualDom$attribute('fx');
var _elm_lang$svg$Svg_Attributes$from = _elm_lang$virtual_dom$VirtualDom$attribute('from');
var _elm_lang$svg$Svg_Attributes$format = _elm_lang$virtual_dom$VirtualDom$attribute('format');
var _elm_lang$svg$Svg_Attributes$filterUnits = _elm_lang$virtual_dom$VirtualDom$attribute('filterUnits');
var _elm_lang$svg$Svg_Attributes$filterRes = _elm_lang$virtual_dom$VirtualDom$attribute('filterRes');
var _elm_lang$svg$Svg_Attributes$externalResourcesRequired = _elm_lang$virtual_dom$VirtualDom$attribute('externalResourcesRequired');
var _elm_lang$svg$Svg_Attributes$exponent = _elm_lang$virtual_dom$VirtualDom$attribute('exponent');
var _elm_lang$svg$Svg_Attributes$end = _elm_lang$virtual_dom$VirtualDom$attribute('end');
var _elm_lang$svg$Svg_Attributes$elevation = _elm_lang$virtual_dom$VirtualDom$attribute('elevation');
var _elm_lang$svg$Svg_Attributes$edgeMode = _elm_lang$virtual_dom$VirtualDom$attribute('edgeMode');
var _elm_lang$svg$Svg_Attributes$dy = _elm_lang$virtual_dom$VirtualDom$attribute('dy');
var _elm_lang$svg$Svg_Attributes$dx = _elm_lang$virtual_dom$VirtualDom$attribute('dx');
var _elm_lang$svg$Svg_Attributes$dur = _elm_lang$virtual_dom$VirtualDom$attribute('dur');
var _elm_lang$svg$Svg_Attributes$divisor = _elm_lang$virtual_dom$VirtualDom$attribute('divisor');
var _elm_lang$svg$Svg_Attributes$diffuseConstant = _elm_lang$virtual_dom$VirtualDom$attribute('diffuseConstant');
var _elm_lang$svg$Svg_Attributes$descent = _elm_lang$virtual_dom$VirtualDom$attribute('descent');
var _elm_lang$svg$Svg_Attributes$decelerate = _elm_lang$virtual_dom$VirtualDom$attribute('decelerate');
var _elm_lang$svg$Svg_Attributes$d = _elm_lang$virtual_dom$VirtualDom$attribute('d');
var _elm_lang$svg$Svg_Attributes$cy = _elm_lang$virtual_dom$VirtualDom$attribute('cy');
var _elm_lang$svg$Svg_Attributes$cx = _elm_lang$virtual_dom$VirtualDom$attribute('cx');
var _elm_lang$svg$Svg_Attributes$contentStyleType = _elm_lang$virtual_dom$VirtualDom$attribute('contentStyleType');
var _elm_lang$svg$Svg_Attributes$contentScriptType = _elm_lang$virtual_dom$VirtualDom$attribute('contentScriptType');
var _elm_lang$svg$Svg_Attributes$clipPathUnits = _elm_lang$virtual_dom$VirtualDom$attribute('clipPathUnits');
var _elm_lang$svg$Svg_Attributes$class = _elm_lang$virtual_dom$VirtualDom$attribute('class');
var _elm_lang$svg$Svg_Attributes$capHeight = _elm_lang$virtual_dom$VirtualDom$attribute('cap-height');
var _elm_lang$svg$Svg_Attributes$calcMode = _elm_lang$virtual_dom$VirtualDom$attribute('calcMode');
var _elm_lang$svg$Svg_Attributes$by = _elm_lang$virtual_dom$VirtualDom$attribute('by');
var _elm_lang$svg$Svg_Attributes$bias = _elm_lang$virtual_dom$VirtualDom$attribute('bias');
var _elm_lang$svg$Svg_Attributes$begin = _elm_lang$virtual_dom$VirtualDom$attribute('begin');
var _elm_lang$svg$Svg_Attributes$bbox = _elm_lang$virtual_dom$VirtualDom$attribute('bbox');
var _elm_lang$svg$Svg_Attributes$baseProfile = _elm_lang$virtual_dom$VirtualDom$attribute('baseProfile');
var _elm_lang$svg$Svg_Attributes$baseFrequency = _elm_lang$virtual_dom$VirtualDom$attribute('baseFrequency');
var _elm_lang$svg$Svg_Attributes$azimuth = _elm_lang$virtual_dom$VirtualDom$attribute('azimuth');
var _elm_lang$svg$Svg_Attributes$autoReverse = _elm_lang$virtual_dom$VirtualDom$attribute('autoReverse');
var _elm_lang$svg$Svg_Attributes$attributeType = _elm_lang$virtual_dom$VirtualDom$attribute('attributeType');
var _elm_lang$svg$Svg_Attributes$attributeName = _elm_lang$virtual_dom$VirtualDom$attribute('attributeName');
var _elm_lang$svg$Svg_Attributes$ascent = _elm_lang$virtual_dom$VirtualDom$attribute('ascent');
var _elm_lang$svg$Svg_Attributes$arabicForm = _elm_lang$virtual_dom$VirtualDom$attribute('arabic-form');
var _elm_lang$svg$Svg_Attributes$amplitude = _elm_lang$virtual_dom$VirtualDom$attribute('amplitude');
var _elm_lang$svg$Svg_Attributes$allowReorder = _elm_lang$virtual_dom$VirtualDom$attribute('allowReorder');
var _elm_lang$svg$Svg_Attributes$alphabetic = _elm_lang$virtual_dom$VirtualDom$attribute('alphabetic');
var _elm_lang$svg$Svg_Attributes$additive = _elm_lang$virtual_dom$VirtualDom$attribute('additive');
var _elm_lang$svg$Svg_Attributes$accumulate = _elm_lang$virtual_dom$VirtualDom$attribute('accumulate');
var _elm_lang$svg$Svg_Attributes$accelerate = _elm_lang$virtual_dom$VirtualDom$attribute('accelerate');
var _elm_lang$svg$Svg_Attributes$accentHeight = _elm_lang$virtual_dom$VirtualDom$attribute('accent-height');

var _justinmimbs$elm_date_extra$Date_Extra_Facts$msPerSecond = 1000;
var _justinmimbs$elm_date_extra$Date_Extra_Facts$msPerMinute = 60 * _justinmimbs$elm_date_extra$Date_Extra_Facts$msPerSecond;
var _justinmimbs$elm_date_extra$Date_Extra_Facts$msPerHour = 60 * _justinmimbs$elm_date_extra$Date_Extra_Facts$msPerMinute;
var _justinmimbs$elm_date_extra$Date_Extra_Facts$msPerDay = 24 * _justinmimbs$elm_date_extra$Date_Extra_Facts$msPerHour;
var _justinmimbs$elm_date_extra$Date_Extra_Facts$dayOfWeekFromWeekdayNumber = function (n) {
	var _p0 = n;
	switch (_p0) {
		case 1:
			return _elm_lang$core$Date$Mon;
		case 2:
			return _elm_lang$core$Date$Tue;
		case 3:
			return _elm_lang$core$Date$Wed;
		case 4:
			return _elm_lang$core$Date$Thu;
		case 5:
			return _elm_lang$core$Date$Fri;
		case 6:
			return _elm_lang$core$Date$Sat;
		default:
			return _elm_lang$core$Date$Sun;
	}
};
var _justinmimbs$elm_date_extra$Date_Extra_Facts$weekdayNumberFromDayOfWeek = function (d) {
	var _p1 = d;
	switch (_p1.ctor) {
		case 'Mon':
			return 1;
		case 'Tue':
			return 2;
		case 'Wed':
			return 3;
		case 'Thu':
			return 4;
		case 'Fri':
			return 5;
		case 'Sat':
			return 6;
		default:
			return 7;
	}
};
var _justinmimbs$elm_date_extra$Date_Extra_Facts$monthFromMonthNumber = function (n) {
	var _p2 = n;
	switch (_p2) {
		case 1:
			return _elm_lang$core$Date$Jan;
		case 2:
			return _elm_lang$core$Date$Feb;
		case 3:
			return _elm_lang$core$Date$Mar;
		case 4:
			return _elm_lang$core$Date$Apr;
		case 5:
			return _elm_lang$core$Date$May;
		case 6:
			return _elm_lang$core$Date$Jun;
		case 7:
			return _elm_lang$core$Date$Jul;
		case 8:
			return _elm_lang$core$Date$Aug;
		case 9:
			return _elm_lang$core$Date$Sep;
		case 10:
			return _elm_lang$core$Date$Oct;
		case 11:
			return _elm_lang$core$Date$Nov;
		default:
			return _elm_lang$core$Date$Dec;
	}
};
var _justinmimbs$elm_date_extra$Date_Extra_Facts$monthNumberFromMonth = function (m) {
	var _p3 = m;
	switch (_p3.ctor) {
		case 'Jan':
			return 1;
		case 'Feb':
			return 2;
		case 'Mar':
			return 3;
		case 'Apr':
			return 4;
		case 'May':
			return 5;
		case 'Jun':
			return 6;
		case 'Jul':
			return 7;
		case 'Aug':
			return 8;
		case 'Sep':
			return 9;
		case 'Oct':
			return 10;
		case 'Nov':
			return 11;
		default:
			return 12;
	}
};
var _justinmimbs$elm_date_extra$Date_Extra_Facts$months = {
	ctor: '::',
	_0: _elm_lang$core$Date$Jan,
	_1: {
		ctor: '::',
		_0: _elm_lang$core$Date$Feb,
		_1: {
			ctor: '::',
			_0: _elm_lang$core$Date$Mar,
			_1: {
				ctor: '::',
				_0: _elm_lang$core$Date$Apr,
				_1: {
					ctor: '::',
					_0: _elm_lang$core$Date$May,
					_1: {
						ctor: '::',
						_0: _elm_lang$core$Date$Jun,
						_1: {
							ctor: '::',
							_0: _elm_lang$core$Date$Jul,
							_1: {
								ctor: '::',
								_0: _elm_lang$core$Date$Aug,
								_1: {
									ctor: '::',
									_0: _elm_lang$core$Date$Sep,
									_1: {
										ctor: '::',
										_0: _elm_lang$core$Date$Oct,
										_1: {
											ctor: '::',
											_0: _elm_lang$core$Date$Nov,
											_1: {
												ctor: '::',
												_0: _elm_lang$core$Date$Dec,
												_1: {ctor: '[]'}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
};
var _justinmimbs$elm_date_extra$Date_Extra_Facts$isLeapYear = function (y) {
	return (_elm_lang$core$Native_Utils.eq(
		A2(_elm_lang$core$Basics_ops['%'], y, 4),
		0) && (!_elm_lang$core$Native_Utils.eq(
		A2(_elm_lang$core$Basics_ops['%'], y, 100),
		0))) || _elm_lang$core$Native_Utils.eq(
		A2(_elm_lang$core$Basics_ops['%'], y, 400),
		0);
};
var _justinmimbs$elm_date_extra$Date_Extra_Facts$daysInMonth = F2(
	function (y, m) {
		var _p4 = m;
		switch (_p4.ctor) {
			case 'Jan':
				return 31;
			case 'Feb':
				return _justinmimbs$elm_date_extra$Date_Extra_Facts$isLeapYear(y) ? 29 : 28;
			case 'Mar':
				return 31;
			case 'Apr':
				return 30;
			case 'May':
				return 31;
			case 'Jun':
				return 30;
			case 'Jul':
				return 31;
			case 'Aug':
				return 31;
			case 'Sep':
				return 30;
			case 'Oct':
				return 31;
			case 'Nov':
				return 30;
			default:
				return 31;
		}
	});
var _justinmimbs$elm_date_extra$Date_Extra_Facts$daysBeforeStartOfMonth = F2(
	function (y, m) {
		var _p5 = m;
		switch (_p5.ctor) {
			case 'Jan':
				return 0;
			case 'Feb':
				return 31;
			case 'Mar':
				return _justinmimbs$elm_date_extra$Date_Extra_Facts$isLeapYear(y) ? 60 : 59;
			case 'Apr':
				return _justinmimbs$elm_date_extra$Date_Extra_Facts$isLeapYear(y) ? 91 : 90;
			case 'May':
				return _justinmimbs$elm_date_extra$Date_Extra_Facts$isLeapYear(y) ? 121 : 120;
			case 'Jun':
				return _justinmimbs$elm_date_extra$Date_Extra_Facts$isLeapYear(y) ? 152 : 151;
			case 'Jul':
				return _justinmimbs$elm_date_extra$Date_Extra_Facts$isLeapYear(y) ? 182 : 181;
			case 'Aug':
				return _justinmimbs$elm_date_extra$Date_Extra_Facts$isLeapYear(y) ? 213 : 212;
			case 'Sep':
				return _justinmimbs$elm_date_extra$Date_Extra_Facts$isLeapYear(y) ? 244 : 243;
			case 'Oct':
				return _justinmimbs$elm_date_extra$Date_Extra_Facts$isLeapYear(y) ? 274 : 273;
			case 'Nov':
				return _justinmimbs$elm_date_extra$Date_Extra_Facts$isLeapYear(y) ? 305 : 304;
			default:
				return _justinmimbs$elm_date_extra$Date_Extra_Facts$isLeapYear(y) ? 335 : 334;
		}
	});

var _justinmimbs$elm_date_extra$Date_Internal_RataDie$toUnixTime = function (rd) {
	return (rd - 719163) * _justinmimbs$elm_date_extra$Date_Extra_Facts$msPerDay;
};
var _justinmimbs$elm_date_extra$Date_Internal_RataDie$weekdayNumber = function (rd) {
	var _p0 = A2(_elm_lang$core$Basics_ops['%'], rd, 7);
	if (_p0 === 0) {
		return 7;
	} else {
		return _p0;
	}
};
var _justinmimbs$elm_date_extra$Date_Internal_RataDie$leapYearsInCommonEra = function (y) {
	return (((y / 4) | 0) - ((y / 100) | 0)) + ((y / 400) | 0);
};
var _justinmimbs$elm_date_extra$Date_Internal_RataDie$rataDieBeforeStartOfYear = function (y) {
	return (365 * (y - 1)) + _justinmimbs$elm_date_extra$Date_Internal_RataDie$leapYearsInCommonEra(y - 1);
};
var _justinmimbs$elm_date_extra$Date_Internal_RataDie$fromOrdinalDate = F2(
	function (y, d) {
		return _justinmimbs$elm_date_extra$Date_Internal_RataDie$rataDieBeforeStartOfYear(y) + d;
	});
var _justinmimbs$elm_date_extra$Date_Internal_RataDie$week1Day1OfWeekYear = function (y) {
	var jan4RD = A2(_justinmimbs$elm_date_extra$Date_Internal_RataDie$fromOrdinalDate, y, 4);
	return (jan4RD - _justinmimbs$elm_date_extra$Date_Internal_RataDie$weekdayNumber(jan4RD)) + 1;
};
var _justinmimbs$elm_date_extra$Date_Internal_RataDie$fromWeekDate = F3(
	function (y, w, d) {
		var week1Day0RD = _justinmimbs$elm_date_extra$Date_Internal_RataDie$week1Day1OfWeekYear(y) - 1;
		return (week1Day0RD + ((w - 1) * 7)) + d;
	});
var _justinmimbs$elm_date_extra$Date_Internal_RataDie$fromCalendarDate = F3(
	function (y, m, d) {
		var md = A2(_justinmimbs$elm_date_extra$Date_Extra_Facts$daysBeforeStartOfMonth, y, m);
		var yd = _justinmimbs$elm_date_extra$Date_Internal_RataDie$rataDieBeforeStartOfYear(y);
		return (yd + md) + d;
	});
var _justinmimbs$elm_date_extra$Date_Internal_RataDie$divideInt = F2(
	function (a, b) {
		return {
			ctor: '_Tuple2',
			_0: (a / b) | 0,
			_1: A2(_elm_lang$core$Basics$rem, a, b)
		};
	});
var _justinmimbs$elm_date_extra$Date_Internal_RataDie$year = function (rd) {
	var _p1 = A2(_justinmimbs$elm_date_extra$Date_Internal_RataDie$divideInt, rd, 146097);
	var q400 = _p1._0;
	var r400 = _p1._1;
	var _p2 = A2(_justinmimbs$elm_date_extra$Date_Internal_RataDie$divideInt, r400, 36524);
	var q100 = _p2._0;
	var r100 = _p2._1;
	var _p3 = A2(_justinmimbs$elm_date_extra$Date_Internal_RataDie$divideInt, r100, 1461);
	var q4 = _p3._0;
	var r4 = _p3._1;
	var _p4 = A2(_justinmimbs$elm_date_extra$Date_Internal_RataDie$divideInt, r4, 365);
	var q1 = _p4._0;
	var r1 = _p4._1;
	var n = _elm_lang$core$Native_Utils.eq(r1, 0) ? 0 : 1;
	return ((((q400 * 400) + (q100 * 100)) + (q4 * 4)) + q1) + n;
};
var _justinmimbs$elm_date_extra$Date_Internal_RataDie$ordinalDay = function (rd) {
	return rd - _justinmimbs$elm_date_extra$Date_Internal_RataDie$rataDieBeforeStartOfYear(
		_justinmimbs$elm_date_extra$Date_Internal_RataDie$year(rd));
};
var _justinmimbs$elm_date_extra$Date_Internal_RataDie$weekYear = function (rd) {
	var daysToThursday = 4 - _justinmimbs$elm_date_extra$Date_Internal_RataDie$weekdayNumber(rd);
	return _justinmimbs$elm_date_extra$Date_Internal_RataDie$year(rd + daysToThursday);
};
var _justinmimbs$elm_date_extra$Date_Internal_RataDie$weekNumber = function (rd) {
	var week1Day1RD = _justinmimbs$elm_date_extra$Date_Internal_RataDie$week1Day1OfWeekYear(
		_justinmimbs$elm_date_extra$Date_Internal_RataDie$weekYear(rd));
	return (((rd - week1Day1RD) / 7) | 0) + 1;
};
var _justinmimbs$elm_date_extra$Date_Internal_RataDie$find = F2(
	function (pred, list) {
		find:
		while (true) {
			var _p5 = list;
			if (_p5.ctor === '[]') {
				return _elm_lang$core$Maybe$Nothing;
			} else {
				var _p6 = _p5._0;
				if (pred(_p6)) {
					return _elm_lang$core$Maybe$Just(_p6);
				} else {
					var _v2 = pred,
						_v3 = _p5._1;
					pred = _v2;
					list = _v3;
					continue find;
				}
			}
		}
	});
var _justinmimbs$elm_date_extra$Date_Internal_RataDie$month = function (rd) {
	var od = _justinmimbs$elm_date_extra$Date_Internal_RataDie$ordinalDay(rd);
	var y = _justinmimbs$elm_date_extra$Date_Internal_RataDie$year(rd);
	return A2(
		_elm_lang$core$Maybe$withDefault,
		_elm_lang$core$Date$Jan,
		A2(
			_justinmimbs$elm_date_extra$Date_Internal_RataDie$find,
			function (m) {
				return _elm_lang$core$Native_Utils.cmp(
					A2(_justinmimbs$elm_date_extra$Date_Extra_Facts$daysBeforeStartOfMonth, y, m),
					od) < 0;
			},
			_elm_lang$core$List$reverse(_justinmimbs$elm_date_extra$Date_Extra_Facts$months)));
};
var _justinmimbs$elm_date_extra$Date_Internal_RataDie$day = function (rd) {
	var od = _justinmimbs$elm_date_extra$Date_Internal_RataDie$ordinalDay(rd);
	var m = _justinmimbs$elm_date_extra$Date_Internal_RataDie$month(rd);
	var y = _justinmimbs$elm_date_extra$Date_Internal_RataDie$year(rd);
	return od - A2(_justinmimbs$elm_date_extra$Date_Extra_Facts$daysBeforeStartOfMonth, y, m);
};

var _justinmimbs$elm_date_extra$Date_Internal_Core$weekNumberFromCalendarDate = F3(
	function (y, m, d) {
		return _justinmimbs$elm_date_extra$Date_Internal_RataDie$weekNumber(
			A3(_justinmimbs$elm_date_extra$Date_Internal_RataDie$fromCalendarDate, y, m, d));
	});
var _justinmimbs$elm_date_extra$Date_Internal_Core$weekYearFromCalendarDate = F3(
	function (y, m, d) {
		return _justinmimbs$elm_date_extra$Date_Internal_RataDie$weekYear(
			A3(_justinmimbs$elm_date_extra$Date_Internal_RataDie$fromCalendarDate, y, m, d));
	});
var _justinmimbs$elm_date_extra$Date_Internal_Core$unixTimeFromOrdinalDate = F2(
	function (y, d) {
		return _justinmimbs$elm_date_extra$Date_Internal_RataDie$toUnixTime(
			A2(_justinmimbs$elm_date_extra$Date_Internal_RataDie$fromOrdinalDate, y, d));
	});
var _justinmimbs$elm_date_extra$Date_Internal_Core$unixTimeFromWeekDate = F3(
	function (y, w, d) {
		return _justinmimbs$elm_date_extra$Date_Internal_RataDie$toUnixTime(
			A3(_justinmimbs$elm_date_extra$Date_Internal_RataDie$fromWeekDate, y, w, d));
	});
var _justinmimbs$elm_date_extra$Date_Internal_Core$unixTimeFromCalendarDate = F3(
	function (y, m, d) {
		return _justinmimbs$elm_date_extra$Date_Internal_RataDie$toUnixTime(
			A3(_justinmimbs$elm_date_extra$Date_Internal_RataDie$fromCalendarDate, y, m, d));
	});
var _justinmimbs$elm_date_extra$Date_Internal_Core$msFromTimeParts = F4(
	function (hh, mm, ss, ms) {
		return ((ms + (_justinmimbs$elm_date_extra$Date_Extra_Facts$msPerSecond * ss)) + (_justinmimbs$elm_date_extra$Date_Extra_Facts$msPerMinute * mm)) + (_justinmimbs$elm_date_extra$Date_Extra_Facts$msPerHour * hh);
	});
var _justinmimbs$elm_date_extra$Date_Internal_Core$unixTimeFromParts = F7(
	function (y, m, d, hh, mm, ss, ms) {
		return _justinmimbs$elm_date_extra$Date_Internal_RataDie$toUnixTime(
			A3(_justinmimbs$elm_date_extra$Date_Internal_RataDie$fromCalendarDate, y, m, d)) + A4(_justinmimbs$elm_date_extra$Date_Internal_Core$msFromTimeParts, hh, mm, ss, ms);
	});

var _justinmimbs$elm_date_extra$Date_Internal_Extract$msOffsetFromUtc = function (date) {
	var utcTime = _elm_lang$core$Date$toTime(date);
	var localTime = _elm_lang$core$Basics$toFloat(
		A7(
			_justinmimbs$elm_date_extra$Date_Internal_Core$unixTimeFromParts,
			_elm_lang$core$Date$year(date),
			_elm_lang$core$Date$month(date),
			_elm_lang$core$Date$day(date),
			_elm_lang$core$Date$hour(date),
			_elm_lang$core$Date$minute(date),
			_elm_lang$core$Date$second(date),
			_elm_lang$core$Date$millisecond(date)));
	return _elm_lang$core$Basics$floor(localTime - utcTime);
};
var _justinmimbs$elm_date_extra$Date_Internal_Extract$offsetFromUtc = function (date) {
	return (_justinmimbs$elm_date_extra$Date_Internal_Extract$msOffsetFromUtc(date) / _justinmimbs$elm_date_extra$Date_Extra_Facts$msPerMinute) | 0;
};
var _justinmimbs$elm_date_extra$Date_Internal_Extract$weekYear = function (date) {
	return A3(
		_justinmimbs$elm_date_extra$Date_Internal_Core$weekYearFromCalendarDate,
		_elm_lang$core$Date$year(date),
		_elm_lang$core$Date$month(date),
		_elm_lang$core$Date$day(date));
};
var _justinmimbs$elm_date_extra$Date_Internal_Extract$weekNumber = function (date) {
	return A3(
		_justinmimbs$elm_date_extra$Date_Internal_Core$weekNumberFromCalendarDate,
		_elm_lang$core$Date$year(date),
		_elm_lang$core$Date$month(date),
		_elm_lang$core$Date$day(date));
};
var _justinmimbs$elm_date_extra$Date_Internal_Extract$weekdayNumber = function (_p0) {
	return _justinmimbs$elm_date_extra$Date_Extra_Facts$weekdayNumberFromDayOfWeek(
		_elm_lang$core$Date$dayOfWeek(_p0));
};
var _justinmimbs$elm_date_extra$Date_Internal_Extract$fractionalDay = function (date) {
	var timeOfDayMS = A4(
		_justinmimbs$elm_date_extra$Date_Internal_Core$msFromTimeParts,
		_elm_lang$core$Date$hour(date),
		_elm_lang$core$Date$minute(date),
		_elm_lang$core$Date$second(date),
		_elm_lang$core$Date$millisecond(date));
	return _elm_lang$core$Basics$toFloat(timeOfDayMS) / _elm_lang$core$Basics$toFloat(_justinmimbs$elm_date_extra$Date_Extra_Facts$msPerDay);
};
var _justinmimbs$elm_date_extra$Date_Internal_Extract$ordinalDay = function (date) {
	return A2(
		_justinmimbs$elm_date_extra$Date_Extra_Facts$daysBeforeStartOfMonth,
		_elm_lang$core$Date$year(date),
		_elm_lang$core$Date$month(date)) + _elm_lang$core$Date$day(date);
};
var _justinmimbs$elm_date_extra$Date_Internal_Extract$monthNumber = function (_p1) {
	return _justinmimbs$elm_date_extra$Date_Extra_Facts$monthNumberFromMonth(
		_elm_lang$core$Date$month(_p1));
};
var _justinmimbs$elm_date_extra$Date_Internal_Extract$quarter = function (date) {
	return _elm_lang$core$Basics$ceiling(
		function (n) {
			return n / 3;
		}(
			_elm_lang$core$Basics$toFloat(
				_justinmimbs$elm_date_extra$Date_Internal_Extract$monthNumber(date))));
};

var _justinmimbs$elm_date_extra$Date_Internal_Format$toUtc = function (date) {
	return _elm_lang$core$Date$fromTime(
		_elm_lang$core$Date$toTime(date) - _elm_lang$core$Basics$toFloat(
			_justinmimbs$elm_date_extra$Date_Internal_Extract$offsetFromUtc(date) * _justinmimbs$elm_date_extra$Date_Extra_Facts$msPerMinute));
};
var _justinmimbs$elm_date_extra$Date_Internal_Format$nameForm = function (length) {
	var _p0 = length;
	switch (_p0) {
		case 1:
			return 'abbreviated';
		case 2:
			return 'abbreviated';
		case 3:
			return 'abbreviated';
		case 4:
			return 'full';
		case 5:
			return 'narrow';
		case 6:
			return 'short';
		default:
			return 'invalid';
	}
};
var _justinmimbs$elm_date_extra$Date_Internal_Format$patternMatches = _elm_lang$core$Regex$regex('([yYQMwdDEeabhHmsSXx])\\1*|\'(?:[^\']|\'\')*?\'(?!\')');
var _justinmimbs$elm_date_extra$Date_Internal_Format$formatTimeOffset = F3(
	function (separator, minutesOptional, offset) {
		var mm = A3(
			_elm_lang$core$String$padLeft,
			2,
			_elm_lang$core$Native_Utils.chr('0'),
			_elm_lang$core$Basics$toString(
				A2(
					_elm_lang$core$Basics_ops['%'],
					_elm_lang$core$Basics$abs(offset),
					60)));
		var hh = A3(
			_elm_lang$core$String$padLeft,
			2,
			_elm_lang$core$Native_Utils.chr('0'),
			_elm_lang$core$Basics$toString(
				(_elm_lang$core$Basics$abs(offset) / 60) | 0));
		var sign = (_elm_lang$core$Native_Utils.cmp(offset, 0) > -1) ? '+' : '-';
		return (minutesOptional && _elm_lang$core$Native_Utils.eq(mm, '00')) ? A2(_elm_lang$core$Basics_ops['++'], sign, hh) : A2(
			_elm_lang$core$Basics_ops['++'],
			sign,
			A2(
				_elm_lang$core$Basics_ops['++'],
				hh,
				A2(_elm_lang$core$Basics_ops['++'], separator, mm)));
	});
var _justinmimbs$elm_date_extra$Date_Internal_Format$ordinalSuffix = function (n) {
	var nn = A2(_elm_lang$core$Basics_ops['%'], n, 100);
	var _p1 = A2(
		_elm_lang$core$Basics$min,
		(_elm_lang$core$Native_Utils.cmp(nn, 20) < 0) ? nn : A2(_elm_lang$core$Basics_ops['%'], nn, 10),
		4);
	switch (_p1) {
		case 0:
			return 'th';
		case 1:
			return 'st';
		case 2:
			return 'nd';
		case 3:
			return 'rd';
		case 4:
			return 'th';
		default:
			return '';
	}
};
var _justinmimbs$elm_date_extra$Date_Internal_Format$withOrdinalSuffix = function (n) {
	return A2(
		_elm_lang$core$Basics_ops['++'],
		_elm_lang$core$Basics$toString(n),
		_justinmimbs$elm_date_extra$Date_Internal_Format$ordinalSuffix(n));
};
var _justinmimbs$elm_date_extra$Date_Internal_Format$hour12 = function (date) {
	var _p2 = A2(
		_elm_lang$core$Basics_ops['%'],
		_elm_lang$core$Date$hour(date),
		12);
	if (_p2 === 0) {
		return 12;
	} else {
		return _p2;
	}
};
var _justinmimbs$elm_date_extra$Date_Internal_Format$dayOfWeekName = function (d) {
	var _p3 = d;
	switch (_p3.ctor) {
		case 'Mon':
			return 'Monday';
		case 'Tue':
			return 'Tuesday';
		case 'Wed':
			return 'Wednesday';
		case 'Thu':
			return 'Thursday';
		case 'Fri':
			return 'Friday';
		case 'Sat':
			return 'Saturday';
		default:
			return 'Sunday';
	}
};
var _justinmimbs$elm_date_extra$Date_Internal_Format$monthName = function (m) {
	var _p4 = m;
	switch (_p4.ctor) {
		case 'Jan':
			return 'January';
		case 'Feb':
			return 'February';
		case 'Mar':
			return 'March';
		case 'Apr':
			return 'April';
		case 'May':
			return 'May';
		case 'Jun':
			return 'June';
		case 'Jul':
			return 'July';
		case 'Aug':
			return 'August';
		case 'Sep':
			return 'September';
		case 'Oct':
			return 'October';
		case 'Nov':
			return 'November';
		default:
			return 'December';
	}
};
var _justinmimbs$elm_date_extra$Date_Internal_Format$PM = {ctor: 'PM'};
var _justinmimbs$elm_date_extra$Date_Internal_Format$Noon = {ctor: 'Noon'};
var _justinmimbs$elm_date_extra$Date_Internal_Format$AM = {ctor: 'AM'};
var _justinmimbs$elm_date_extra$Date_Internal_Format$Midnight = {ctor: 'Midnight'};
var _justinmimbs$elm_date_extra$Date_Internal_Format$dayPeriod = function (date) {
	var onTheHour = _elm_lang$core$Native_Utils.eq(
		_elm_lang$core$Date$minute(date),
		0) && (_elm_lang$core$Native_Utils.eq(
		_elm_lang$core$Date$second(date),
		0) && _elm_lang$core$Native_Utils.eq(
		_elm_lang$core$Date$millisecond(date),
		0));
	var hh = _elm_lang$core$Date$hour(date);
	return (_elm_lang$core$Native_Utils.eq(hh, 0) && onTheHour) ? _justinmimbs$elm_date_extra$Date_Internal_Format$Midnight : ((_elm_lang$core$Native_Utils.cmp(hh, 12) < 0) ? _justinmimbs$elm_date_extra$Date_Internal_Format$AM : ((_elm_lang$core$Native_Utils.eq(hh, 12) && onTheHour) ? _justinmimbs$elm_date_extra$Date_Internal_Format$Noon : _justinmimbs$elm_date_extra$Date_Internal_Format$PM));
};
var _justinmimbs$elm_date_extra$Date_Internal_Format$format = F3(
	function (asUtc, date, match) {
		format:
		while (true) {
			var length = _elm_lang$core$String$length(match);
			var $char = A2(_elm_lang$core$String$left, 1, match);
			var _p5 = $char;
			switch (_p5) {
				case 'y':
					var _p6 = length;
					if (_p6 === 2) {
						return A2(
							_elm_lang$core$String$right,
							2,
							A3(
								_elm_lang$core$String$padLeft,
								length,
								_elm_lang$core$Native_Utils.chr('0'),
								_elm_lang$core$Basics$toString(
									_elm_lang$core$Date$year(date))));
					} else {
						return A3(
							_elm_lang$core$String$padLeft,
							length,
							_elm_lang$core$Native_Utils.chr('0'),
							_elm_lang$core$Basics$toString(
								_elm_lang$core$Date$year(date)));
					}
				case 'Y':
					var _p7 = length;
					if (_p7 === 2) {
						return A2(
							_elm_lang$core$String$right,
							2,
							A3(
								_elm_lang$core$String$padLeft,
								length,
								_elm_lang$core$Native_Utils.chr('0'),
								_elm_lang$core$Basics$toString(
									_justinmimbs$elm_date_extra$Date_Internal_Extract$weekYear(date))));
					} else {
						return A3(
							_elm_lang$core$String$padLeft,
							length,
							_elm_lang$core$Native_Utils.chr('0'),
							_elm_lang$core$Basics$toString(
								_justinmimbs$elm_date_extra$Date_Internal_Extract$weekYear(date)));
					}
				case 'Q':
					var _p8 = length;
					switch (_p8) {
						case 1:
							return _elm_lang$core$Basics$toString(
								_justinmimbs$elm_date_extra$Date_Internal_Extract$quarter(date));
						case 2:
							return _elm_lang$core$Basics$toString(
								_justinmimbs$elm_date_extra$Date_Internal_Extract$quarter(date));
						case 3:
							return A2(
								F2(
									function (x, y) {
										return A2(_elm_lang$core$Basics_ops['++'], x, y);
									}),
								'Q',
								_elm_lang$core$Basics$toString(
									_justinmimbs$elm_date_extra$Date_Internal_Extract$quarter(date)));
						case 4:
							return _justinmimbs$elm_date_extra$Date_Internal_Format$withOrdinalSuffix(
								_justinmimbs$elm_date_extra$Date_Internal_Extract$quarter(date));
						case 5:
							return _elm_lang$core$Basics$toString(
								_justinmimbs$elm_date_extra$Date_Internal_Extract$quarter(date));
						default:
							return '';
					}
				case 'M':
					var _p9 = length;
					switch (_p9) {
						case 1:
							return _elm_lang$core$Basics$toString(
								_justinmimbs$elm_date_extra$Date_Internal_Extract$monthNumber(date));
						case 2:
							return A3(
								_elm_lang$core$String$padLeft,
								2,
								_elm_lang$core$Native_Utils.chr('0'),
								_elm_lang$core$Basics$toString(
									_justinmimbs$elm_date_extra$Date_Internal_Extract$monthNumber(date)));
						case 3:
							return A2(
								_elm_lang$core$String$left,
								3,
								_justinmimbs$elm_date_extra$Date_Internal_Format$monthName(
									_elm_lang$core$Date$month(date)));
						case 4:
							return _justinmimbs$elm_date_extra$Date_Internal_Format$monthName(
								_elm_lang$core$Date$month(date));
						case 5:
							return A2(
								_elm_lang$core$String$left,
								1,
								_justinmimbs$elm_date_extra$Date_Internal_Format$monthName(
									_elm_lang$core$Date$month(date)));
						default:
							return '';
					}
				case 'w':
					var _p10 = length;
					switch (_p10) {
						case 1:
							return _elm_lang$core$Basics$toString(
								_justinmimbs$elm_date_extra$Date_Internal_Extract$weekNumber(date));
						case 2:
							return A3(
								_elm_lang$core$String$padLeft,
								2,
								_elm_lang$core$Native_Utils.chr('0'),
								_elm_lang$core$Basics$toString(
									_justinmimbs$elm_date_extra$Date_Internal_Extract$weekNumber(date)));
						default:
							return '';
					}
				case 'd':
					var _p11 = length;
					switch (_p11) {
						case 1:
							return _elm_lang$core$Basics$toString(
								_elm_lang$core$Date$day(date));
						case 2:
							return A3(
								_elm_lang$core$String$padLeft,
								2,
								_elm_lang$core$Native_Utils.chr('0'),
								_elm_lang$core$Basics$toString(
									_elm_lang$core$Date$day(date)));
						case 3:
							return _justinmimbs$elm_date_extra$Date_Internal_Format$withOrdinalSuffix(
								_elm_lang$core$Date$day(date));
						default:
							return '';
					}
				case 'D':
					var _p12 = length;
					switch (_p12) {
						case 1:
							return _elm_lang$core$Basics$toString(
								_justinmimbs$elm_date_extra$Date_Internal_Extract$ordinalDay(date));
						case 2:
							return A3(
								_elm_lang$core$String$padLeft,
								2,
								_elm_lang$core$Native_Utils.chr('0'),
								_elm_lang$core$Basics$toString(
									_justinmimbs$elm_date_extra$Date_Internal_Extract$ordinalDay(date)));
						case 3:
							return A3(
								_elm_lang$core$String$padLeft,
								3,
								_elm_lang$core$Native_Utils.chr('0'),
								_elm_lang$core$Basics$toString(
									_justinmimbs$elm_date_extra$Date_Internal_Extract$ordinalDay(date)));
						default:
							return '';
					}
				case 'E':
					var _p13 = _justinmimbs$elm_date_extra$Date_Internal_Format$nameForm(length);
					switch (_p13) {
						case 'abbreviated':
							return A2(
								_elm_lang$core$String$left,
								3,
								_justinmimbs$elm_date_extra$Date_Internal_Format$dayOfWeekName(
									_elm_lang$core$Date$dayOfWeek(date)));
						case 'full':
							return _justinmimbs$elm_date_extra$Date_Internal_Format$dayOfWeekName(
								_elm_lang$core$Date$dayOfWeek(date));
						case 'narrow':
							return A2(
								_elm_lang$core$String$left,
								1,
								_justinmimbs$elm_date_extra$Date_Internal_Format$dayOfWeekName(
									_elm_lang$core$Date$dayOfWeek(date)));
						case 'short':
							return A2(
								_elm_lang$core$String$left,
								2,
								_justinmimbs$elm_date_extra$Date_Internal_Format$dayOfWeekName(
									_elm_lang$core$Date$dayOfWeek(date)));
						default:
							return '';
					}
				case 'e':
					var _p14 = length;
					switch (_p14) {
						case 1:
							return _elm_lang$core$Basics$toString(
								_justinmimbs$elm_date_extra$Date_Internal_Extract$weekdayNumber(date));
						case 2:
							return _elm_lang$core$Basics$toString(
								_justinmimbs$elm_date_extra$Date_Internal_Extract$weekdayNumber(date));
						default:
							var _v15 = asUtc,
								_v16 = date,
								_v17 = _elm_lang$core$String$toUpper(match);
							asUtc = _v15;
							date = _v16;
							match = _v17;
							continue format;
					}
				case 'a':
					var p = _justinmimbs$elm_date_extra$Date_Internal_Format$dayPeriod(date);
					var m = (_elm_lang$core$Native_Utils.eq(p, _justinmimbs$elm_date_extra$Date_Internal_Format$Midnight) || _elm_lang$core$Native_Utils.eq(p, _justinmimbs$elm_date_extra$Date_Internal_Format$AM)) ? 'A' : 'P';
					var _p15 = _justinmimbs$elm_date_extra$Date_Internal_Format$nameForm(length);
					switch (_p15) {
						case 'abbreviated':
							return A2(_elm_lang$core$Basics_ops['++'], m, 'M');
						case 'full':
							return A2(_elm_lang$core$Basics_ops['++'], m, '.M.');
						case 'narrow':
							return m;
						default:
							return '';
					}
				case 'b':
					var _p16 = _justinmimbs$elm_date_extra$Date_Internal_Format$nameForm(length);
					switch (_p16) {
						case 'abbreviated':
							var _p17 = _justinmimbs$elm_date_extra$Date_Internal_Format$dayPeriod(date);
							switch (_p17.ctor) {
								case 'Midnight':
									return 'mid.';
								case 'AM':
									return 'am';
								case 'Noon':
									return 'noon';
								default:
									return 'pm';
							}
						case 'full':
							var _p18 = _justinmimbs$elm_date_extra$Date_Internal_Format$dayPeriod(date);
							switch (_p18.ctor) {
								case 'Midnight':
									return 'midnight';
								case 'AM':
									return 'a.m.';
								case 'Noon':
									return 'noon';
								default:
									return 'p.m.';
							}
						case 'narrow':
							var _p19 = _justinmimbs$elm_date_extra$Date_Internal_Format$dayPeriod(date);
							switch (_p19.ctor) {
								case 'Midnight':
									return 'md';
								case 'AM':
									return 'a';
								case 'Noon':
									return 'nn';
								default:
									return 'p';
							}
						default:
							return '';
					}
				case 'h':
					var _p20 = length;
					switch (_p20) {
						case 1:
							return _elm_lang$core$Basics$toString(
								_justinmimbs$elm_date_extra$Date_Internal_Format$hour12(date));
						case 2:
							return A3(
								_elm_lang$core$String$padLeft,
								2,
								_elm_lang$core$Native_Utils.chr('0'),
								_elm_lang$core$Basics$toString(
									_justinmimbs$elm_date_extra$Date_Internal_Format$hour12(date)));
						default:
							return '';
					}
				case 'H':
					var _p21 = length;
					switch (_p21) {
						case 1:
							return _elm_lang$core$Basics$toString(
								_elm_lang$core$Date$hour(date));
						case 2:
							return A3(
								_elm_lang$core$String$padLeft,
								2,
								_elm_lang$core$Native_Utils.chr('0'),
								_elm_lang$core$Basics$toString(
									_elm_lang$core$Date$hour(date)));
						default:
							return '';
					}
				case 'm':
					var _p22 = length;
					switch (_p22) {
						case 1:
							return _elm_lang$core$Basics$toString(
								_elm_lang$core$Date$minute(date));
						case 2:
							return A3(
								_elm_lang$core$String$padLeft,
								2,
								_elm_lang$core$Native_Utils.chr('0'),
								_elm_lang$core$Basics$toString(
									_elm_lang$core$Date$minute(date)));
						default:
							return '';
					}
				case 's':
					var _p23 = length;
					switch (_p23) {
						case 1:
							return _elm_lang$core$Basics$toString(
								_elm_lang$core$Date$second(date));
						case 2:
							return A3(
								_elm_lang$core$String$padLeft,
								2,
								_elm_lang$core$Native_Utils.chr('0'),
								_elm_lang$core$Basics$toString(
									_elm_lang$core$Date$second(date)));
						default:
							return '';
					}
				case 'S':
					return A3(
						_elm_lang$core$String$padRight,
						length,
						_elm_lang$core$Native_Utils.chr('0'),
						A2(
							_elm_lang$core$String$left,
							length,
							A3(
								_elm_lang$core$String$padLeft,
								3,
								_elm_lang$core$Native_Utils.chr('0'),
								_elm_lang$core$Basics$toString(
									_elm_lang$core$Date$millisecond(date)))));
				case 'X':
					if ((_elm_lang$core$Native_Utils.cmp(length, 4) < 0) && (asUtc || _elm_lang$core$Native_Utils.eq(
						_justinmimbs$elm_date_extra$Date_Internal_Extract$offsetFromUtc(date),
						0))) {
						return 'Z';
					} else {
						var _v27 = asUtc,
							_v28 = date,
							_v29 = _elm_lang$core$String$toLower(match);
						asUtc = _v27;
						date = _v28;
						match = _v29;
						continue format;
					}
				case 'x':
					var offset = asUtc ? 0 : _justinmimbs$elm_date_extra$Date_Internal_Extract$offsetFromUtc(date);
					var _p24 = length;
					switch (_p24) {
						case 1:
							return A3(_justinmimbs$elm_date_extra$Date_Internal_Format$formatTimeOffset, '', true, offset);
						case 2:
							return A3(_justinmimbs$elm_date_extra$Date_Internal_Format$formatTimeOffset, '', false, offset);
						case 3:
							return A3(_justinmimbs$elm_date_extra$Date_Internal_Format$formatTimeOffset, ':', false, offset);
						default:
							return '';
					}
				case '\'':
					return _elm_lang$core$Native_Utils.eq(match, '\'\'') ? '\'' : A4(
						_elm_lang$core$Regex$replace,
						_elm_lang$core$Regex$All,
						_elm_lang$core$Regex$regex('\'\''),
						function (_p25) {
							return '\'';
						},
						A3(_elm_lang$core$String$slice, 1, -1, match));
				default:
					return '';
			}
		}
	});
var _justinmimbs$elm_date_extra$Date_Internal_Format$toFormattedString = F3(
	function (asUtc, pattern, date) {
		var date_ = asUtc ? _justinmimbs$elm_date_extra$Date_Internal_Format$toUtc(date) : date;
		return A4(
			_elm_lang$core$Regex$replace,
			_elm_lang$core$Regex$All,
			_justinmimbs$elm_date_extra$Date_Internal_Format$patternMatches,
			function (_p26) {
				return A3(
					_justinmimbs$elm_date_extra$Date_Internal_Format$format,
					asUtc,
					date_,
					function (_) {
						return _.match;
					}(_p26));
			},
			pattern);
	});

var _justinmimbs$elm_date_extra$Date_Internal_Parse$isoDateRegex = function () {
	var time = 'T(\\d{2})(?:(\\:)?(\\d{2})(?:\\10(\\d{2}))?)?(\\.\\d+)?(?:(Z)|(?:([+\\-])(\\d{2})(?:\\:?(\\d{2}))?))?';
	var ord = '\\-?(\\d{3})';
	var week = '(\\-)?W(\\d{2})(?:\\5(\\d))?';
	var cal = '(\\-)?(\\d{2})(?:\\2(\\d{2}))?';
	var year = '(\\d{4})';
	return _elm_lang$core$Regex$regex(
		A2(
			_elm_lang$core$Basics_ops['++'],
			'^',
			A2(
				_elm_lang$core$Basics_ops['++'],
				year,
				A2(
					_elm_lang$core$Basics_ops['++'],
					'(?:',
					A2(
						_elm_lang$core$Basics_ops['++'],
						cal,
						A2(
							_elm_lang$core$Basics_ops['++'],
							'|',
							A2(
								_elm_lang$core$Basics_ops['++'],
								week,
								A2(
									_elm_lang$core$Basics_ops['++'],
									'|',
									A2(
										_elm_lang$core$Basics_ops['++'],
										ord,
										A2(
											_elm_lang$core$Basics_ops['++'],
											')?',
											A2(
												_elm_lang$core$Basics_ops['++'],
												'(?:',
												A2(_elm_lang$core$Basics_ops['++'], time, ')?$'))))))))))));
}();
var _justinmimbs$elm_date_extra$Date_Internal_Parse$stringToFloat = function (_p0) {
	return _elm_lang$core$Result$toMaybe(
		_elm_lang$core$String$toFloat(_p0));
};
var _justinmimbs$elm_date_extra$Date_Internal_Parse$msFromMatches = F4(
	function (timeHH, timeMM, timeSS, timeF) {
		var fractional = A2(
			_elm_lang$core$Maybe$withDefault,
			0.0,
			A2(_elm_lang$core$Maybe$andThen, _justinmimbs$elm_date_extra$Date_Internal_Parse$stringToFloat, timeF));
		var _p1 = function () {
			var _p2 = A2(
				_elm_lang$core$List$map,
				_elm_lang$core$Maybe$andThen(_justinmimbs$elm_date_extra$Date_Internal_Parse$stringToFloat),
				{
					ctor: '::',
					_0: timeHH,
					_1: {
						ctor: '::',
						_0: timeMM,
						_1: {
							ctor: '::',
							_0: timeSS,
							_1: {ctor: '[]'}
						}
					}
				});
			_v0_3:
			do {
				if (((_p2.ctor === '::') && (_p2._0.ctor === 'Just')) && (_p2._1.ctor === '::')) {
					if (_p2._1._0.ctor === 'Just') {
						if (_p2._1._1.ctor === '::') {
							if (_p2._1._1._0.ctor === 'Just') {
								if (_p2._1._1._1.ctor === '[]') {
									return {ctor: '_Tuple3', _0: _p2._0._0, _1: _p2._1._0._0, _2: _p2._1._1._0._0 + fractional};
								} else {
									break _v0_3;
								}
							} else {
								if (_p2._1._1._1.ctor === '[]') {
									return {ctor: '_Tuple3', _0: _p2._0._0, _1: _p2._1._0._0 + fractional, _2: 0.0};
								} else {
									break _v0_3;
								}
							}
						} else {
							break _v0_3;
						}
					} else {
						if (((_p2._1._1.ctor === '::') && (_p2._1._1._0.ctor === 'Nothing')) && (_p2._1._1._1.ctor === '[]')) {
							return {ctor: '_Tuple3', _0: _p2._0._0 + fractional, _1: 0.0, _2: 0.0};
						} else {
							break _v0_3;
						}
					}
				} else {
					break _v0_3;
				}
			} while(false);
			return {ctor: '_Tuple3', _0: 0.0, _1: 0.0, _2: 0.0};
		}();
		var hh = _p1._0;
		var mm = _p1._1;
		var ss = _p1._2;
		return _elm_lang$core$Basics$round(
			((hh * _elm_lang$core$Basics$toFloat(_justinmimbs$elm_date_extra$Date_Extra_Facts$msPerHour)) + (mm * _elm_lang$core$Basics$toFloat(_justinmimbs$elm_date_extra$Date_Extra_Facts$msPerMinute))) + (ss * _elm_lang$core$Basics$toFloat(_justinmimbs$elm_date_extra$Date_Extra_Facts$msPerSecond)));
	});
var _justinmimbs$elm_date_extra$Date_Internal_Parse$stringToInt = function (_p3) {
	return _elm_lang$core$Result$toMaybe(
		_elm_lang$core$String$toInt(_p3));
};
var _justinmimbs$elm_date_extra$Date_Internal_Parse$unixTimeFromMatches = F6(
	function (yyyy, calMM, calDD, weekWW, weekD, ordDDD) {
		var y = A2(
			_elm_lang$core$Maybe$withDefault,
			1,
			_justinmimbs$elm_date_extra$Date_Internal_Parse$stringToInt(yyyy));
		var _p4 = {ctor: '_Tuple2', _0: calMM, _1: weekWW};
		_v1_2:
		do {
			if (_p4.ctor === '_Tuple2') {
				if (_p4._0.ctor === 'Just') {
					if (_p4._1.ctor === 'Nothing') {
						return A3(
							_justinmimbs$elm_date_extra$Date_Internal_Core$unixTimeFromCalendarDate,
							y,
							_justinmimbs$elm_date_extra$Date_Extra_Facts$monthFromMonthNumber(
								A2(
									_elm_lang$core$Maybe$withDefault,
									1,
									A2(_elm_lang$core$Maybe$andThen, _justinmimbs$elm_date_extra$Date_Internal_Parse$stringToInt, calMM))),
							A2(
								_elm_lang$core$Maybe$withDefault,
								1,
								A2(_elm_lang$core$Maybe$andThen, _justinmimbs$elm_date_extra$Date_Internal_Parse$stringToInt, calDD)));
					} else {
						break _v1_2;
					}
				} else {
					if (_p4._1.ctor === 'Just') {
						return A3(
							_justinmimbs$elm_date_extra$Date_Internal_Core$unixTimeFromWeekDate,
							y,
							A2(
								_elm_lang$core$Maybe$withDefault,
								1,
								A2(_elm_lang$core$Maybe$andThen, _justinmimbs$elm_date_extra$Date_Internal_Parse$stringToInt, weekWW)),
							A2(
								_elm_lang$core$Maybe$withDefault,
								1,
								A2(_elm_lang$core$Maybe$andThen, _justinmimbs$elm_date_extra$Date_Internal_Parse$stringToInt, weekD)));
					} else {
						break _v1_2;
					}
				}
			} else {
				break _v1_2;
			}
		} while(false);
		return A2(
			_justinmimbs$elm_date_extra$Date_Internal_Core$unixTimeFromOrdinalDate,
			y,
			A2(
				_elm_lang$core$Maybe$withDefault,
				1,
				A2(_elm_lang$core$Maybe$andThen, _justinmimbs$elm_date_extra$Date_Internal_Parse$stringToInt, ordDDD)));
	});
var _justinmimbs$elm_date_extra$Date_Internal_Parse$offsetFromMatches = F4(
	function (tzZ, tzSign, tzHH, tzMM) {
		var _p5 = {ctor: '_Tuple2', _0: tzZ, _1: tzSign};
		_v2_2:
		do {
			if (_p5.ctor === '_Tuple2') {
				if (_p5._0.ctor === 'Just') {
					if ((_p5._0._0 === 'Z') && (_p5._1.ctor === 'Nothing')) {
						return _elm_lang$core$Maybe$Just(0);
					} else {
						break _v2_2;
					}
				} else {
					if (_p5._1.ctor === 'Just') {
						var mm = A2(
							_elm_lang$core$Maybe$withDefault,
							0,
							A2(_elm_lang$core$Maybe$andThen, _justinmimbs$elm_date_extra$Date_Internal_Parse$stringToInt, tzMM));
						var hh = A2(
							_elm_lang$core$Maybe$withDefault,
							0,
							A2(_elm_lang$core$Maybe$andThen, _justinmimbs$elm_date_extra$Date_Internal_Parse$stringToInt, tzHH));
						return _elm_lang$core$Maybe$Just(
							(_elm_lang$core$Native_Utils.eq(_p5._1._0, '+') ? 1 : -1) * ((hh * 60) + mm));
					} else {
						break _v2_2;
					}
				}
			} else {
				break _v2_2;
			}
		} while(false);
		return _elm_lang$core$Maybe$Nothing;
	});
var _justinmimbs$elm_date_extra$Date_Internal_Parse$offsetTimeFromMatches = function (matches) {
	var _p6 = matches;
	if (((((((((((((((((((_p6.ctor === '::') && (_p6._0.ctor === 'Just')) && (_p6._1.ctor === '::')) && (_p6._1._1.ctor === '::')) && (_p6._1._1._1.ctor === '::')) && (_p6._1._1._1._1.ctor === '::')) && (_p6._1._1._1._1._1.ctor === '::')) && (_p6._1._1._1._1._1._1.ctor === '::')) && (_p6._1._1._1._1._1._1._1.ctor === '::')) && (_p6._1._1._1._1._1._1._1._1.ctor === '::')) && (_p6._1._1._1._1._1._1._1._1._1.ctor === '::')) && (_p6._1._1._1._1._1._1._1._1._1._1.ctor === '::')) && (_p6._1._1._1._1._1._1._1._1._1._1._1.ctor === '::')) && (_p6._1._1._1._1._1._1._1._1._1._1._1._1.ctor === '::')) && (_p6._1._1._1._1._1._1._1._1._1._1._1._1._1.ctor === '::')) && (_p6._1._1._1._1._1._1._1._1._1._1._1._1._1._1.ctor === '::')) && (_p6._1._1._1._1._1._1._1._1._1._1._1._1._1._1._1.ctor === '::')) && (_p6._1._1._1._1._1._1._1._1._1._1._1._1._1._1._1._1.ctor === '::')) && (_p6._1._1._1._1._1._1._1._1._1._1._1._1._1._1._1._1._1.ctor === '[]')) {
		var offset = A4(_justinmimbs$elm_date_extra$Date_Internal_Parse$offsetFromMatches, _p6._1._1._1._1._1._1._1._1._1._1._1._1._1._0, _p6._1._1._1._1._1._1._1._1._1._1._1._1._1._1._0, _p6._1._1._1._1._1._1._1._1._1._1._1._1._1._1._1._0, _p6._1._1._1._1._1._1._1._1._1._1._1._1._1._1._1._1._0);
		var timeMS = A4(_justinmimbs$elm_date_extra$Date_Internal_Parse$msFromMatches, _p6._1._1._1._1._1._1._1._1._0, _p6._1._1._1._1._1._1._1._1._1._1._0, _p6._1._1._1._1._1._1._1._1._1._1._1._0, _p6._1._1._1._1._1._1._1._1._1._1._1._1._0);
		var dateMS = A6(_justinmimbs$elm_date_extra$Date_Internal_Parse$unixTimeFromMatches, _p6._0._0, _p6._1._1._0, _p6._1._1._1._0, _p6._1._1._1._1._1._0, _p6._1._1._1._1._1._1._0, _p6._1._1._1._1._1._1._1._0);
		return _elm_lang$core$Maybe$Just(
			{ctor: '_Tuple2', _0: offset, _1: dateMS + timeMS});
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _justinmimbs$elm_date_extra$Date_Internal_Parse$offsetTimeFromIsoString = function (s) {
	return A2(
		_elm_lang$core$Maybe$andThen,
		_justinmimbs$elm_date_extra$Date_Internal_Parse$offsetTimeFromMatches,
		A2(
			_elm_lang$core$Maybe$map,
			function (_) {
				return _.submatches;
			},
			_elm_lang$core$List$head(
				A3(
					_elm_lang$core$Regex$find,
					_elm_lang$core$Regex$AtMost(1),
					_justinmimbs$elm_date_extra$Date_Internal_Parse$isoDateRegex,
					s))));
};

var _justinmimbs$elm_date_extra$Date_Extra$unfold = F2(
	function (f, seed) {
		var _p0 = f(seed);
		if (_p0.ctor === 'Nothing') {
			return {ctor: '[]'};
		} else {
			return {
				ctor: '::',
				_0: _p0._0._0,
				_1: A2(_justinmimbs$elm_date_extra$Date_Extra$unfold, f, _p0._0._1)
			};
		}
	});
var _justinmimbs$elm_date_extra$Date_Extra$toParts = function (date) {
	return {
		ctor: '_Tuple7',
		_0: _elm_lang$core$Date$year(date),
		_1: _elm_lang$core$Date$month(date),
		_2: _elm_lang$core$Date$day(date),
		_3: _elm_lang$core$Date$hour(date),
		_4: _elm_lang$core$Date$minute(date),
		_5: _elm_lang$core$Date$second(date),
		_6: _elm_lang$core$Date$millisecond(date)
	};
};
var _justinmimbs$elm_date_extra$Date_Extra$monthFromQuarter = function (q) {
	var _p1 = q;
	switch (_p1) {
		case 1:
			return _elm_lang$core$Date$Jan;
		case 2:
			return _elm_lang$core$Date$Apr;
		case 3:
			return _elm_lang$core$Date$Jul;
		default:
			return _elm_lang$core$Date$Oct;
	}
};
var _justinmimbs$elm_date_extra$Date_Extra$clamp = F3(
	function (min, max, date) {
		return (_elm_lang$core$Native_Utils.cmp(
			_elm_lang$core$Date$toTime(date),
			_elm_lang$core$Date$toTime(min)) < 0) ? min : ((_elm_lang$core$Native_Utils.cmp(
			_elm_lang$core$Date$toTime(date),
			_elm_lang$core$Date$toTime(max)) > 0) ? max : date);
	});
var _justinmimbs$elm_date_extra$Date_Extra$comparableIsBetween = F3(
	function (a, b, x) {
		return ((_elm_lang$core$Native_Utils.cmp(a, x) < 1) && (_elm_lang$core$Native_Utils.cmp(x, b) < 1)) || ((_elm_lang$core$Native_Utils.cmp(b, x) < 1) && (_elm_lang$core$Native_Utils.cmp(x, a) < 1));
	});
var _justinmimbs$elm_date_extra$Date_Extra$isBetween = F3(
	function (date1, date2, date) {
		return A3(
			_justinmimbs$elm_date_extra$Date_Extra$comparableIsBetween,
			_elm_lang$core$Date$toTime(date1),
			_elm_lang$core$Date$toTime(date2),
			_elm_lang$core$Date$toTime(date));
	});
var _justinmimbs$elm_date_extra$Date_Extra$compare = F2(
	function (a, b) {
		return A2(
			_elm_lang$core$Basics$compare,
			_elm_lang$core$Date$toTime(a),
			_elm_lang$core$Date$toTime(b));
	});
var _justinmimbs$elm_date_extra$Date_Extra$equal = F2(
	function (a, b) {
		return _elm_lang$core$Native_Utils.eq(
			_elm_lang$core$Date$toTime(a),
			_elm_lang$core$Date$toTime(b));
	});
var _justinmimbs$elm_date_extra$Date_Extra$offsetFromUtc = _justinmimbs$elm_date_extra$Date_Internal_Extract$offsetFromUtc;
var _justinmimbs$elm_date_extra$Date_Extra$weekYear = _justinmimbs$elm_date_extra$Date_Internal_Extract$weekYear;
var _justinmimbs$elm_date_extra$Date_Extra$weekNumber = _justinmimbs$elm_date_extra$Date_Internal_Extract$weekNumber;
var _justinmimbs$elm_date_extra$Date_Extra$weekdayNumber = _justinmimbs$elm_date_extra$Date_Internal_Extract$weekdayNumber;
var _justinmimbs$elm_date_extra$Date_Extra$daysToPreviousDayOfWeek = F2(
	function (d, date) {
		return _elm_lang$core$Basics$negate(
			A2(
				_elm_lang$core$Basics_ops['%'],
				(_justinmimbs$elm_date_extra$Date_Extra$weekdayNumber(date) - _justinmimbs$elm_date_extra$Date_Extra_Facts$weekdayNumberFromDayOfWeek(d)) + 7,
				7));
	});
var _justinmimbs$elm_date_extra$Date_Extra$fractionalDay = _justinmimbs$elm_date_extra$Date_Internal_Extract$fractionalDay;
var _justinmimbs$elm_date_extra$Date_Extra$ordinalDay = _justinmimbs$elm_date_extra$Date_Internal_Extract$ordinalDay;
var _justinmimbs$elm_date_extra$Date_Extra$quarter = _justinmimbs$elm_date_extra$Date_Internal_Extract$quarter;
var _justinmimbs$elm_date_extra$Date_Extra$monthNumber = _justinmimbs$elm_date_extra$Date_Internal_Extract$monthNumber;
var _justinmimbs$elm_date_extra$Date_Extra$ordinalMonth = function (date) {
	return (_elm_lang$core$Date$year(date) * 12) + _justinmimbs$elm_date_extra$Date_Extra$monthNumber(date);
};
var _justinmimbs$elm_date_extra$Date_Extra$diffMonth = F2(
	function (date1, date2) {
		var fractionalMonth = function (date) {
			return (_elm_lang$core$Basics$toFloat(
				_elm_lang$core$Date$day(date) - 1) + _justinmimbs$elm_date_extra$Date_Extra$fractionalDay(date)) / 31;
		};
		var ordinalMonthFloat = function (date) {
			return _elm_lang$core$Basics$toFloat(
				_justinmimbs$elm_date_extra$Date_Extra$ordinalMonth(date)) + fractionalMonth(date);
		};
		return _elm_lang$core$Basics$truncate(
			ordinalMonthFloat(date2) - ordinalMonthFloat(date1));
	});
var _justinmimbs$elm_date_extra$Date_Extra$toUtcFormattedString = _justinmimbs$elm_date_extra$Date_Internal_Format$toFormattedString(true);
var _justinmimbs$elm_date_extra$Date_Extra$toUtcIsoString = _justinmimbs$elm_date_extra$Date_Extra$toUtcFormattedString('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
var _justinmimbs$elm_date_extra$Date_Extra$toFormattedString = _justinmimbs$elm_date_extra$Date_Internal_Format$toFormattedString(false);
var _justinmimbs$elm_date_extra$Date_Extra$toIsoString = _justinmimbs$elm_date_extra$Date_Extra$toFormattedString('yyyy-MM-dd\'T\'HH:mm:ss.SSSxxx');
var _justinmimbs$elm_date_extra$Date_Extra$fromTime = function (_p2) {
	return _elm_lang$core$Date$fromTime(
		_elm_lang$core$Basics$toFloat(_p2));
};
var _justinmimbs$elm_date_extra$Date_Extra$fromOffsetTime = function (_p3) {
	var _p4 = _p3;
	var _p6 = _p4._1;
	var _p5 = _p4._0;
	if (_p5.ctor === 'Just') {
		return _justinmimbs$elm_date_extra$Date_Extra$fromTime(_p6 - (_justinmimbs$elm_date_extra$Date_Extra_Facts$msPerMinute * _p5._0));
	} else {
		var offset0 = _justinmimbs$elm_date_extra$Date_Extra$offsetFromUtc(
			_justinmimbs$elm_date_extra$Date_Extra$fromTime(_p6));
		var date1 = _justinmimbs$elm_date_extra$Date_Extra$fromTime(_p6 - (_justinmimbs$elm_date_extra$Date_Extra_Facts$msPerMinute * offset0));
		var offset1 = _justinmimbs$elm_date_extra$Date_Extra$offsetFromUtc(date1);
		if (_elm_lang$core$Native_Utils.eq(offset0, offset1)) {
			return date1;
		} else {
			var date2 = _justinmimbs$elm_date_extra$Date_Extra$fromTime(_p6 - (_justinmimbs$elm_date_extra$Date_Extra_Facts$msPerMinute * offset1));
			var offset2 = _justinmimbs$elm_date_extra$Date_Extra$offsetFromUtc(date2);
			return _elm_lang$core$Native_Utils.eq(offset1, offset2) ? date2 : date1;
		}
	}
};
var _justinmimbs$elm_date_extra$Date_Extra$fromParts = F7(
	function (y, m, d, hh, mm, ss, ms) {
		return _justinmimbs$elm_date_extra$Date_Extra$fromOffsetTime(
			{
				ctor: '_Tuple2',
				_0: _elm_lang$core$Maybe$Nothing,
				_1: A7(_justinmimbs$elm_date_extra$Date_Internal_Core$unixTimeFromParts, y, m, d, hh, mm, ss, ms)
			});
	});
var _justinmimbs$elm_date_extra$Date_Extra$addMonths = F2(
	function (n, date) {
		var om = (_justinmimbs$elm_date_extra$Date_Extra$ordinalMonth(date) + n) + -1;
		var y_ = (om / 12) | 0;
		var m_ = _justinmimbs$elm_date_extra$Date_Extra_Facts$monthFromMonthNumber(
			A2(_elm_lang$core$Basics_ops['%'], om, 12) + 1);
		var _p7 = _justinmimbs$elm_date_extra$Date_Extra$toParts(date);
		var y = _p7._0;
		var m = _p7._1;
		var d = _p7._2;
		var hh = _p7._3;
		var mm = _p7._4;
		var ss = _p7._5;
		var ms = _p7._6;
		var d_ = A2(
			_elm_lang$core$Basics$min,
			d,
			A2(_justinmimbs$elm_date_extra$Date_Extra_Facts$daysInMonth, y_, m_));
		return A7(_justinmimbs$elm_date_extra$Date_Extra$fromParts, y_, m_, d_, hh, mm, ss, ms);
	});
var _justinmimbs$elm_date_extra$Date_Extra$add = F3(
	function (interval, n, date) {
		var _p8 = _justinmimbs$elm_date_extra$Date_Extra$toParts(date);
		var y = _p8._0;
		var m = _p8._1;
		var d = _p8._2;
		var hh = _p8._3;
		var mm = _p8._4;
		var ss = _p8._5;
		var ms = _p8._6;
		var _p9 = interval;
		switch (_p9.ctor) {
			case 'Millisecond':
				return _elm_lang$core$Date$fromTime(
					_elm_lang$core$Date$toTime(date) + _elm_lang$core$Basics$toFloat(n));
			case 'Second':
				return _elm_lang$core$Date$fromTime(
					_elm_lang$core$Date$toTime(date) + _elm_lang$core$Basics$toFloat(n * _justinmimbs$elm_date_extra$Date_Extra_Facts$msPerSecond));
			case 'Minute':
				return _elm_lang$core$Date$fromTime(
					_elm_lang$core$Date$toTime(date) + _elm_lang$core$Basics$toFloat(n * _justinmimbs$elm_date_extra$Date_Extra_Facts$msPerMinute));
			case 'Hour':
				return _elm_lang$core$Date$fromTime(
					_elm_lang$core$Date$toTime(date) + _elm_lang$core$Basics$toFloat(n * _justinmimbs$elm_date_extra$Date_Extra_Facts$msPerHour));
			case 'Day':
				return A7(_justinmimbs$elm_date_extra$Date_Extra$fromParts, y, m, d + n, hh, mm, ss, ms);
			case 'Month':
				return A2(_justinmimbs$elm_date_extra$Date_Extra$addMonths, n, date);
			case 'Year':
				return A2(_justinmimbs$elm_date_extra$Date_Extra$addMonths, n * 12, date);
			case 'Quarter':
				return A2(_justinmimbs$elm_date_extra$Date_Extra$addMonths, n * 3, date);
			case 'Week':
				return A7(_justinmimbs$elm_date_extra$Date_Extra$fromParts, y, m, d + (n * 7), hh, mm, ss, ms);
			default:
				return A7(_justinmimbs$elm_date_extra$Date_Extra$fromParts, y, m, d + (n * 7), hh, mm, ss, ms);
		}
	});
var _justinmimbs$elm_date_extra$Date_Extra$fromCalendarDate = F3(
	function (y, m, d) {
		return _justinmimbs$elm_date_extra$Date_Extra$fromOffsetTime(
			{
				ctor: '_Tuple2',
				_0: _elm_lang$core$Maybe$Nothing,
				_1: A3(_justinmimbs$elm_date_extra$Date_Internal_Core$unixTimeFromCalendarDate, y, m, d)
			});
	});
var _justinmimbs$elm_date_extra$Date_Extra$floor = F2(
	function (interval, date) {
		var _p10 = _justinmimbs$elm_date_extra$Date_Extra$toParts(date);
		var y = _p10._0;
		var m = _p10._1;
		var d = _p10._2;
		var hh = _p10._3;
		var mm = _p10._4;
		var ss = _p10._5;
		var _p11 = interval;
		switch (_p11.ctor) {
			case 'Millisecond':
				return date;
			case 'Second':
				return A7(_justinmimbs$elm_date_extra$Date_Extra$fromParts, y, m, d, hh, mm, ss, 0);
			case 'Minute':
				return A7(_justinmimbs$elm_date_extra$Date_Extra$fromParts, y, m, d, hh, mm, 0, 0);
			case 'Hour':
				return A7(_justinmimbs$elm_date_extra$Date_Extra$fromParts, y, m, d, hh, 0, 0, 0);
			case 'Day':
				return A3(_justinmimbs$elm_date_extra$Date_Extra$fromCalendarDate, y, m, d);
			case 'Month':
				return A3(_justinmimbs$elm_date_extra$Date_Extra$fromCalendarDate, y, m, 1);
			case 'Year':
				return A3(_justinmimbs$elm_date_extra$Date_Extra$fromCalendarDate, y, _elm_lang$core$Date$Jan, 1);
			case 'Quarter':
				return A3(
					_justinmimbs$elm_date_extra$Date_Extra$fromCalendarDate,
					y,
					_justinmimbs$elm_date_extra$Date_Extra$monthFromQuarter(
						_justinmimbs$elm_date_extra$Date_Extra$quarter(date)),
					1);
			case 'Week':
				return A3(
					_justinmimbs$elm_date_extra$Date_Extra$fromCalendarDate,
					y,
					m,
					d + A2(_justinmimbs$elm_date_extra$Date_Extra$daysToPreviousDayOfWeek, _elm_lang$core$Date$Mon, date));
			case 'Monday':
				return A3(
					_justinmimbs$elm_date_extra$Date_Extra$fromCalendarDate,
					y,
					m,
					d + A2(_justinmimbs$elm_date_extra$Date_Extra$daysToPreviousDayOfWeek, _elm_lang$core$Date$Mon, date));
			case 'Tuesday':
				return A3(
					_justinmimbs$elm_date_extra$Date_Extra$fromCalendarDate,
					y,
					m,
					d + A2(_justinmimbs$elm_date_extra$Date_Extra$daysToPreviousDayOfWeek, _elm_lang$core$Date$Tue, date));
			case 'Wednesday':
				return A3(
					_justinmimbs$elm_date_extra$Date_Extra$fromCalendarDate,
					y,
					m,
					d + A2(_justinmimbs$elm_date_extra$Date_Extra$daysToPreviousDayOfWeek, _elm_lang$core$Date$Wed, date));
			case 'Thursday':
				return A3(
					_justinmimbs$elm_date_extra$Date_Extra$fromCalendarDate,
					y,
					m,
					d + A2(_justinmimbs$elm_date_extra$Date_Extra$daysToPreviousDayOfWeek, _elm_lang$core$Date$Thu, date));
			case 'Friday':
				return A3(
					_justinmimbs$elm_date_extra$Date_Extra$fromCalendarDate,
					y,
					m,
					d + A2(_justinmimbs$elm_date_extra$Date_Extra$daysToPreviousDayOfWeek, _elm_lang$core$Date$Fri, date));
			case 'Saturday':
				return A3(
					_justinmimbs$elm_date_extra$Date_Extra$fromCalendarDate,
					y,
					m,
					d + A2(_justinmimbs$elm_date_extra$Date_Extra$daysToPreviousDayOfWeek, _elm_lang$core$Date$Sat, date));
			default:
				return A3(
					_justinmimbs$elm_date_extra$Date_Extra$fromCalendarDate,
					y,
					m,
					d + A2(_justinmimbs$elm_date_extra$Date_Extra$daysToPreviousDayOfWeek, _elm_lang$core$Date$Sun, date));
		}
	});
var _justinmimbs$elm_date_extra$Date_Extra$ceiling = F2(
	function (interval, date) {
		var floored = A2(_justinmimbs$elm_date_extra$Date_Extra$floor, interval, date);
		return _elm_lang$core$Native_Utils.eq(
			_elm_lang$core$Date$toTime(date),
			_elm_lang$core$Date$toTime(floored)) ? date : A3(_justinmimbs$elm_date_extra$Date_Extra$add, interval, 1, floored);
	});
var _justinmimbs$elm_date_extra$Date_Extra$range = F4(
	function (interval, step, start, end) {
		var next = function (date) {
			return (_elm_lang$core$Native_Utils.cmp(
				_elm_lang$core$Date$toTime(date),
				_elm_lang$core$Date$toTime(end)) > -1) ? _elm_lang$core$Maybe$Nothing : _elm_lang$core$Maybe$Just(
				{
					ctor: '_Tuple2',
					_0: date,
					_1: A3(
						_justinmimbs$elm_date_extra$Date_Extra$add,
						interval,
						A2(_elm_lang$core$Basics$max, 1, step),
						date)
				});
		};
		return A2(
			_justinmimbs$elm_date_extra$Date_Extra$unfold,
			next,
			A2(_justinmimbs$elm_date_extra$Date_Extra$ceiling, interval, start));
	});
var _justinmimbs$elm_date_extra$Date_Extra$fromIsoString = function (_p12) {
	return A2(
		_elm_lang$core$Maybe$map,
		_justinmimbs$elm_date_extra$Date_Extra$fromOffsetTime,
		_justinmimbs$elm_date_extra$Date_Internal_Parse$offsetTimeFromIsoString(_p12));
};
var _justinmimbs$elm_date_extra$Date_Extra$fromSpec = F3(
	function (_p15, _p14, _p13) {
		var _p16 = _p15;
		var _p17 = _p14;
		var _p18 = _p13;
		return _justinmimbs$elm_date_extra$Date_Extra$fromOffsetTime(
			{ctor: '_Tuple2', _0: _p16._0, _1: _p18._0 + _p17._0});
	});
var _justinmimbs$elm_date_extra$Date_Extra$Offset = function (a) {
	return {ctor: 'Offset', _0: a};
};
var _justinmimbs$elm_date_extra$Date_Extra$utc = _justinmimbs$elm_date_extra$Date_Extra$Offset(
	_elm_lang$core$Maybe$Just(0));
var _justinmimbs$elm_date_extra$Date_Extra$offset = function (minutes) {
	return _justinmimbs$elm_date_extra$Date_Extra$Offset(
		_elm_lang$core$Maybe$Just(minutes));
};
var _justinmimbs$elm_date_extra$Date_Extra$local = _justinmimbs$elm_date_extra$Date_Extra$Offset(_elm_lang$core$Maybe$Nothing);
var _justinmimbs$elm_date_extra$Date_Extra$TimeMS = function (a) {
	return {ctor: 'TimeMS', _0: a};
};
var _justinmimbs$elm_date_extra$Date_Extra$noTime = _justinmimbs$elm_date_extra$Date_Extra$TimeMS(0);
var _justinmimbs$elm_date_extra$Date_Extra$atTime = F4(
	function (hh, mm, ss, ms) {
		return _justinmimbs$elm_date_extra$Date_Extra$TimeMS(
			A4(_justinmimbs$elm_date_extra$Date_Internal_Core$msFromTimeParts, hh, mm, ss, ms));
	});
var _justinmimbs$elm_date_extra$Date_Extra$DateMS = function (a) {
	return {ctor: 'DateMS', _0: a};
};
var _justinmimbs$elm_date_extra$Date_Extra$calendarDate = F3(
	function (y, m, d) {
		return _justinmimbs$elm_date_extra$Date_Extra$DateMS(
			A3(_justinmimbs$elm_date_extra$Date_Internal_Core$unixTimeFromCalendarDate, y, m, d));
	});
var _justinmimbs$elm_date_extra$Date_Extra$ordinalDate = F2(
	function (y, d) {
		return _justinmimbs$elm_date_extra$Date_Extra$DateMS(
			A2(_justinmimbs$elm_date_extra$Date_Internal_Core$unixTimeFromOrdinalDate, y, d));
	});
var _justinmimbs$elm_date_extra$Date_Extra$weekDate = F3(
	function (y, w, d) {
		return _justinmimbs$elm_date_extra$Date_Extra$DateMS(
			A3(_justinmimbs$elm_date_extra$Date_Internal_Core$unixTimeFromWeekDate, y, w, d));
	});
var _justinmimbs$elm_date_extra$Date_Extra$Sunday = {ctor: 'Sunday'};
var _justinmimbs$elm_date_extra$Date_Extra$Saturday = {ctor: 'Saturday'};
var _justinmimbs$elm_date_extra$Date_Extra$Friday = {ctor: 'Friday'};
var _justinmimbs$elm_date_extra$Date_Extra$Thursday = {ctor: 'Thursday'};
var _justinmimbs$elm_date_extra$Date_Extra$Wednesday = {ctor: 'Wednesday'};
var _justinmimbs$elm_date_extra$Date_Extra$Tuesday = {ctor: 'Tuesday'};
var _justinmimbs$elm_date_extra$Date_Extra$Monday = {ctor: 'Monday'};
var _justinmimbs$elm_date_extra$Date_Extra$Week = {ctor: 'Week'};
var _justinmimbs$elm_date_extra$Date_Extra$Quarter = {ctor: 'Quarter'};
var _justinmimbs$elm_date_extra$Date_Extra$Year = {ctor: 'Year'};
var _justinmimbs$elm_date_extra$Date_Extra$Month = {ctor: 'Month'};
var _justinmimbs$elm_date_extra$Date_Extra$Day = {ctor: 'Day'};
var _justinmimbs$elm_date_extra$Date_Extra$diff = F3(
	function (interval, date1, date2) {
		var diffMS = _elm_lang$core$Basics$floor(
			_elm_lang$core$Date$toTime(date2) - _elm_lang$core$Date$toTime(date1));
		var _p19 = interval;
		switch (_p19.ctor) {
			case 'Millisecond':
				return diffMS;
			case 'Second':
				return (diffMS / _justinmimbs$elm_date_extra$Date_Extra_Facts$msPerSecond) | 0;
			case 'Minute':
				return (diffMS / _justinmimbs$elm_date_extra$Date_Extra_Facts$msPerMinute) | 0;
			case 'Hour':
				return (diffMS / _justinmimbs$elm_date_extra$Date_Extra_Facts$msPerHour) | 0;
			case 'Day':
				return (diffMS / _justinmimbs$elm_date_extra$Date_Extra_Facts$msPerDay) | 0;
			case 'Month':
				return A2(_justinmimbs$elm_date_extra$Date_Extra$diffMonth, date1, date2);
			case 'Year':
				return (A2(_justinmimbs$elm_date_extra$Date_Extra$diffMonth, date1, date2) / 12) | 0;
			case 'Quarter':
				return (A2(_justinmimbs$elm_date_extra$Date_Extra$diffMonth, date1, date2) / 3) | 0;
			case 'Week':
				return (A3(_justinmimbs$elm_date_extra$Date_Extra$diff, _justinmimbs$elm_date_extra$Date_Extra$Day, date1, date2) / 7) | 0;
			default:
				var _p20 = _p19;
				return (A3(
					_justinmimbs$elm_date_extra$Date_Extra$diff,
					_justinmimbs$elm_date_extra$Date_Extra$Day,
					A2(_justinmimbs$elm_date_extra$Date_Extra$floor, _p20, date1),
					A2(_justinmimbs$elm_date_extra$Date_Extra$floor, _p20, date2)) / 7) | 0;
		}
	});
var _justinmimbs$elm_date_extra$Date_Extra$Hour = {ctor: 'Hour'};
var _justinmimbs$elm_date_extra$Date_Extra$Minute = {ctor: 'Minute'};
var _justinmimbs$elm_date_extra$Date_Extra$equalBy = F3(
	function (interval, date1, date2) {
		equalBy:
		while (true) {
			var _p21 = interval;
			switch (_p21.ctor) {
				case 'Millisecond':
					return _elm_lang$core$Native_Utils.eq(
						_elm_lang$core$Date$toTime(date1),
						_elm_lang$core$Date$toTime(date2));
				case 'Second':
					return _elm_lang$core$Native_Utils.eq(
						_elm_lang$core$Date$second(date1),
						_elm_lang$core$Date$second(date2)) && A3(_justinmimbs$elm_date_extra$Date_Extra$equalBy, _justinmimbs$elm_date_extra$Date_Extra$Minute, date1, date2);
				case 'Minute':
					return _elm_lang$core$Native_Utils.eq(
						_elm_lang$core$Date$minute(date1),
						_elm_lang$core$Date$minute(date2)) && A3(_justinmimbs$elm_date_extra$Date_Extra$equalBy, _justinmimbs$elm_date_extra$Date_Extra$Hour, date1, date2);
				case 'Hour':
					return _elm_lang$core$Native_Utils.eq(
						_elm_lang$core$Date$hour(date1),
						_elm_lang$core$Date$hour(date2)) && A3(_justinmimbs$elm_date_extra$Date_Extra$equalBy, _justinmimbs$elm_date_extra$Date_Extra$Day, date1, date2);
				case 'Day':
					return _elm_lang$core$Native_Utils.eq(
						_elm_lang$core$Date$day(date1),
						_elm_lang$core$Date$day(date2)) && A3(_justinmimbs$elm_date_extra$Date_Extra$equalBy, _justinmimbs$elm_date_extra$Date_Extra$Month, date1, date2);
				case 'Month':
					return _elm_lang$core$Native_Utils.eq(
						_elm_lang$core$Date$month(date1),
						_elm_lang$core$Date$month(date2)) && A3(_justinmimbs$elm_date_extra$Date_Extra$equalBy, _justinmimbs$elm_date_extra$Date_Extra$Year, date1, date2);
				case 'Year':
					return _elm_lang$core$Native_Utils.eq(
						_elm_lang$core$Date$year(date1),
						_elm_lang$core$Date$year(date2));
				case 'Quarter':
					return _elm_lang$core$Native_Utils.eq(
						_justinmimbs$elm_date_extra$Date_Extra$quarter(date1),
						_justinmimbs$elm_date_extra$Date_Extra$quarter(date2)) && A3(_justinmimbs$elm_date_extra$Date_Extra$equalBy, _justinmimbs$elm_date_extra$Date_Extra$Year, date1, date2);
				case 'Week':
					return _elm_lang$core$Native_Utils.eq(
						_justinmimbs$elm_date_extra$Date_Extra$weekNumber(date1),
						_justinmimbs$elm_date_extra$Date_Extra$weekNumber(date2)) && _elm_lang$core$Native_Utils.eq(
						_justinmimbs$elm_date_extra$Date_Extra$weekYear(date1),
						_justinmimbs$elm_date_extra$Date_Extra$weekYear(date2));
				default:
					var _p22 = _p21;
					var _v11 = _justinmimbs$elm_date_extra$Date_Extra$Day,
						_v12 = A2(_justinmimbs$elm_date_extra$Date_Extra$floor, _p22, date1),
						_v13 = A2(_justinmimbs$elm_date_extra$Date_Extra$floor, _p22, date2);
					interval = _v11;
					date1 = _v12;
					date2 = _v13;
					continue equalBy;
			}
		}
	});
var _justinmimbs$elm_date_extra$Date_Extra$Second = {ctor: 'Second'};
var _justinmimbs$elm_date_extra$Date_Extra$Millisecond = {ctor: 'Millisecond'};

var _justinmimbs$elm_date_selector$DateSelector$dayOfWeekNames = {
	ctor: '::',
	_0: 'Mo',
	_1: {
		ctor: '::',
		_0: 'Tu',
		_1: {
			ctor: '::',
			_0: 'We',
			_1: {
				ctor: '::',
				_0: 'Th',
				_1: {
					ctor: '::',
					_0: 'Fr',
					_1: {
						ctor: '::',
						_0: 'Sa',
						_1: {
							ctor: '::',
							_0: 'Su',
							_1: {ctor: '[]'}
						}
					}
				}
			}
		}
	}
};
var _justinmimbs$elm_date_selector$DateSelector$viewDayOfWeekHeader = A2(
	_elm_lang$html$Html$thead,
	{ctor: '[]'},
	{
		ctor: '::',
		_0: A2(
			_elm_lang$html$Html$tr,
			{ctor: '[]'},
			A2(
				_elm_lang$core$List$map,
				function (name) {
					return A2(
						_elm_lang$html$Html$th,
						{ctor: '[]'},
						{
							ctor: '::',
							_0: _elm_lang$html$Html$text(name),
							_1: {ctor: '[]'}
						});
				},
				_justinmimbs$elm_date_selector$DateSelector$dayOfWeekNames)),
		_1: {ctor: '[]'}
	});
var _justinmimbs$elm_date_selector$DateSelector$monthNames = {
	ctor: '::',
	_0: 'Jan',
	_1: {
		ctor: '::',
		_0: 'Feb',
		_1: {
			ctor: '::',
			_0: 'Mar',
			_1: {
				ctor: '::',
				_0: 'Apr',
				_1: {
					ctor: '::',
					_0: 'May',
					_1: {
						ctor: '::',
						_0: 'Jun',
						_1: {
							ctor: '::',
							_0: 'Jul',
							_1: {
								ctor: '::',
								_0: 'Aug',
								_1: {
									ctor: '::',
									_0: 'Sep',
									_1: {
										ctor: '::',
										_0: 'Oct',
										_1: {
											ctor: '::',
											_0: 'Nov',
											_1: {
												ctor: '::',
												_0: 'Dec',
												_1: {ctor: '[]'}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
};
var _justinmimbs$elm_date_selector$DateSelector$classNameFromState = function (state) {
	var _p0 = state;
	switch (_p0.ctor) {
		case 'Normal':
			return '';
		case 'Dimmed':
			return 'date-selector--dimmed';
		case 'Disabled':
			return 'date-selector--disabled';
		default:
			return 'date-selector--selected';
	}
};
var _justinmimbs$elm_date_selector$DateSelector$dateWithMonth = F2(
	function (date, m) {
		var d = _elm_lang$core$Date$day(date);
		var y = _elm_lang$core$Date$year(date);
		return A3(
			_justinmimbs$elm_date_extra$Date_Extra$fromCalendarDate,
			y,
			m,
			A2(
				_elm_lang$core$Basics$min,
				d,
				A2(_justinmimbs$elm_date_extra$Date_Extra_Facts$daysInMonth, y, m)));
	});
var _justinmimbs$elm_date_selector$DateSelector$dateWithYear = F2(
	function (date, y) {
		var d = _elm_lang$core$Date$day(date);
		var m = _elm_lang$core$Date$month(date);
		return (_elm_lang$core$Native_Utils.eq(m, _elm_lang$core$Date$Feb) && (_elm_lang$core$Native_Utils.eq(d, 29) && (!_justinmimbs$elm_date_extra$Date_Extra_Facts$isLeapYear(y)))) ? A3(_justinmimbs$elm_date_extra$Date_Extra$fromCalendarDate, y, _elm_lang$core$Date$Feb, 28) : A3(_justinmimbs$elm_date_extra$Date_Extra$fromCalendarDate, y, m, d);
	});
var _justinmimbs$elm_date_selector$DateSelector$monthDates = F2(
	function (y, m) {
		var start = A2(
			_justinmimbs$elm_date_extra$Date_Extra$floor,
			_justinmimbs$elm_date_extra$Date_Extra$Monday,
			A3(_justinmimbs$elm_date_extra$Date_Extra$fromCalendarDate, y, m, 1));
		return A4(
			_justinmimbs$elm_date_extra$Date_Extra$range,
			_justinmimbs$elm_date_extra$Date_Extra$Day,
			1,
			start,
			A3(_justinmimbs$elm_date_extra$Date_Extra$add, _justinmimbs$elm_date_extra$Date_Extra$Day, 42, start));
	});
var _justinmimbs$elm_date_selector$DateSelector$isBetween = F3(
	function (a, b, x) {
		return ((_elm_lang$core$Native_Utils.cmp(a, x) < 1) && (_elm_lang$core$Native_Utils.cmp(x, b) < 1)) || ((_elm_lang$core$Native_Utils.cmp(b, x) < 1) && (_elm_lang$core$Native_Utils.cmp(x, a) < 1));
	});
var _justinmimbs$elm_date_selector$DateSelector$groupsOf = F2(
	function (n, list) {
		return _elm_lang$core$List$isEmpty(list) ? {ctor: '[]'} : {
			ctor: '::',
			_0: A2(_elm_lang$core$List$take, n, list),
			_1: A2(
				_justinmimbs$elm_date_selector$DateSelector$groupsOf,
				n,
				A2(_elm_lang$core$List$drop, n, list))
		};
	});
var _justinmimbs$elm_date_selector$DateSelector$Selected = {ctor: 'Selected'};
var _justinmimbs$elm_date_selector$DateSelector$Disabled = {ctor: 'Disabled'};
var _justinmimbs$elm_date_selector$DateSelector$viewMonthListDisabled = A2(
	_elm_lang$html$Html$ol,
	{ctor: '[]'},
	A2(
		_elm_lang$core$List$map,
		function (name) {
			return A2(
				_elm_lang$html$Html$li,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class(
						_justinmimbs$elm_date_selector$DateSelector$classNameFromState(_justinmimbs$elm_date_selector$DateSelector$Disabled)),
					_1: {ctor: '[]'}
				},
				{
					ctor: '::',
					_0: _elm_lang$html$Html$text(name),
					_1: {ctor: '[]'}
				});
		},
		_justinmimbs$elm_date_selector$DateSelector$monthNames));
var _justinmimbs$elm_date_selector$DateSelector$viewDateTableDisabled = function (date) {
	var disabled = _justinmimbs$elm_date_selector$DateSelector$classNameFromState(_justinmimbs$elm_date_selector$DateSelector$Disabled);
	var weeks = A2(
		_justinmimbs$elm_date_selector$DateSelector$groupsOf,
		7,
		A2(
			_justinmimbs$elm_date_selector$DateSelector$monthDates,
			_elm_lang$core$Date$year(date),
			_elm_lang$core$Date$month(date)));
	return A2(
		_elm_lang$html$Html$table,
		{ctor: '[]'},
		{
			ctor: '::',
			_0: _justinmimbs$elm_date_selector$DateSelector$viewDayOfWeekHeader,
			_1: {
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$tbody,
					{ctor: '[]'},
					A2(
						_elm_lang$core$List$map,
						function (week) {
							return A2(
								_elm_lang$html$Html$tr,
								{ctor: '[]'},
								A2(
									_elm_lang$core$List$map,
									function (date) {
										return A2(
											_elm_lang$html$Html$td,
											{
												ctor: '::',
												_0: _elm_lang$html$Html_Attributes$class(disabled),
												_1: {ctor: '[]'}
											},
											{
												ctor: '::',
												_0: _elm_lang$html$Html$text(
													_elm_lang$core$Basics$toString(
														_elm_lang$core$Date$day(date))),
												_1: {ctor: '[]'}
											});
									},
									week));
						},
						weeks)),
				_1: {ctor: '[]'}
			}
		});
};
var _justinmimbs$elm_date_selector$DateSelector$Dimmed = {ctor: 'Dimmed'};
var _justinmimbs$elm_date_selector$DateSelector$Normal = {ctor: 'Normal'};
var _justinmimbs$elm_date_selector$DateSelector$isSelectable = function (state) {
	return _elm_lang$core$Native_Utils.eq(state, _justinmimbs$elm_date_selector$DateSelector$Normal) || _elm_lang$core$Native_Utils.eq(state, _justinmimbs$elm_date_selector$DateSelector$Dimmed);
};
var _justinmimbs$elm_date_selector$DateSelector$viewYearList = F3(
	function (minimum, maximum, maybeSelected) {
		var isSelectedYear = A2(
			_elm_lang$core$Maybe$withDefault,
			function (_p1) {
				return false;
			},
			A2(
				_elm_lang$core$Maybe$map,
				function (selected) {
					return F2(
						function (x, y) {
							return _elm_lang$core$Native_Utils.eq(x, y);
						})(
						_elm_lang$core$Date$year(selected));
				},
				maybeSelected));
		var isInvertedMinMax = _elm_lang$core$Native_Utils.eq(
			A2(_justinmimbs$elm_date_extra$Date_Extra$compare, minimum, maximum),
			_elm_lang$core$Basics$GT);
		var years = isInvertedMinMax ? {
			ctor: '::',
			_0: _elm_lang$core$Date$year(
				A2(_elm_lang$core$Maybe$withDefault, minimum, maybeSelected)),
			_1: {ctor: '[]'}
		} : A2(
			_elm_lang$core$List$range,
			_elm_lang$core$Date$year(minimum),
			_elm_lang$core$Date$year(maximum));
		return A2(
			_elm_lang$html$Html$ol,
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html_Events$on,
					'click',
					A2(
						_elm_lang$core$Json_Decode$map,
						_justinmimbs$elm_date_selector$DateSelector$dateWithYear(
							A2(
								_elm_lang$core$Maybe$withDefault,
								A3(
									_justinmimbs$elm_date_extra$Date_Extra$fromCalendarDate,
									_elm_lang$core$Date$year(minimum),
									_elm_lang$core$Date$Jan,
									1),
								maybeSelected)),
						A2(
							_elm_lang$core$Json_Decode$at,
							{
								ctor: '::',
								_0: 'target',
								_1: {
									ctor: '::',
									_0: 'year',
									_1: {ctor: '[]'}
								}
							},
							_elm_lang$core$Json_Decode$int))),
				_1: {ctor: '[]'}
			},
			A2(
				_elm_lang$core$List$map,
				function (y) {
					var state = isSelectedYear(y) ? _justinmimbs$elm_date_selector$DateSelector$Selected : (isInvertedMinMax ? _justinmimbs$elm_date_selector$DateSelector$Disabled : _justinmimbs$elm_date_selector$DateSelector$Normal);
					return A2(
						_elm_lang$html$Html$li,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class(
								_justinmimbs$elm_date_selector$DateSelector$classNameFromState(state)),
							_1: {
								ctor: '::',
								_0: A2(
									_elm_lang$html$Html_Attributes$property,
									'year',
									_justinmimbs$elm_date_selector$DateSelector$isSelectable(state) ? _elm_lang$core$Json_Encode$int(y) : _elm_lang$core$Json_Encode$null),
								_1: {ctor: '[]'}
							}
						},
						{
							ctor: '::',
							_0: _elm_lang$html$Html$text(
								_elm_lang$core$Basics$toString(y)),
							_1: {ctor: '[]'}
						});
				},
				years));
	});
var _justinmimbs$elm_date_selector$DateSelector$viewMonthList = F3(
	function (minimum, maximum, selected) {
		var last = _elm_lang$core$Native_Utils.eq(
			_elm_lang$core$Date$year(selected),
			_elm_lang$core$Date$year(maximum)) ? _justinmimbs$elm_date_extra$Date_Extra$monthNumber(maximum) : 12;
		var first = _elm_lang$core$Native_Utils.eq(
			_elm_lang$core$Date$year(selected),
			_elm_lang$core$Date$year(minimum)) ? _justinmimbs$elm_date_extra$Date_Extra$monthNumber(minimum) : 1;
		var isInvertedMinMax = _elm_lang$core$Native_Utils.eq(
			A2(_justinmimbs$elm_date_extra$Date_Extra$compare, minimum, maximum),
			_elm_lang$core$Basics$GT);
		return A2(
			_elm_lang$html$Html$ol,
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html_Events$on,
					'click',
					A2(
						_elm_lang$core$Json_Decode$map,
						function (_p2) {
							return A2(
								_justinmimbs$elm_date_selector$DateSelector$dateWithMonth,
								selected,
								_justinmimbs$elm_date_extra$Date_Extra_Facts$monthFromMonthNumber(_p2));
						},
						A2(
							_elm_lang$core$Json_Decode$at,
							{
								ctor: '::',
								_0: 'target',
								_1: {
									ctor: '::',
									_0: 'monthNumber',
									_1: {ctor: '[]'}
								}
							},
							_elm_lang$core$Json_Decode$int))),
				_1: {ctor: '[]'}
			},
			A2(
				_elm_lang$core$List$indexedMap,
				F2(
					function (i, name) {
						var n = i + 1;
						var state = _elm_lang$core$Native_Utils.eq(
							n,
							_justinmimbs$elm_date_extra$Date_Extra$monthNumber(selected)) ? _justinmimbs$elm_date_selector$DateSelector$Selected : (((!A3(_justinmimbs$elm_date_selector$DateSelector$isBetween, first, last, n)) || isInvertedMinMax) ? _justinmimbs$elm_date_selector$DateSelector$Disabled : _justinmimbs$elm_date_selector$DateSelector$Normal);
						return A2(
							_elm_lang$html$Html$li,
							{
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$class(
									_justinmimbs$elm_date_selector$DateSelector$classNameFromState(state)),
								_1: {
									ctor: '::',
									_0: A2(
										_elm_lang$html$Html_Attributes$property,
										'monthNumber',
										_justinmimbs$elm_date_selector$DateSelector$isSelectable(state) ? _elm_lang$core$Json_Encode$int(n) : _elm_lang$core$Json_Encode$null),
									_1: {ctor: '[]'}
								}
							},
							{
								ctor: '::',
								_0: _elm_lang$html$Html$text(name),
								_1: {ctor: '[]'}
							});
					}),
				_justinmimbs$elm_date_selector$DateSelector$monthNames));
	});
var _justinmimbs$elm_date_selector$DateSelector$viewDateTable = F3(
	function (minimum, maximum, selected) {
		var weeks = A2(
			_justinmimbs$elm_date_selector$DateSelector$groupsOf,
			7,
			A2(
				_justinmimbs$elm_date_selector$DateSelector$monthDates,
				_elm_lang$core$Date$year(selected),
				_elm_lang$core$Date$month(selected)));
		var isInvertedMinMax = _elm_lang$core$Native_Utils.eq(
			A2(_justinmimbs$elm_date_extra$Date_Extra$compare, minimum, maximum),
			_elm_lang$core$Basics$GT);
		return A2(
			_elm_lang$html$Html$table,
			{ctor: '[]'},
			{
				ctor: '::',
				_0: _justinmimbs$elm_date_selector$DateSelector$viewDayOfWeekHeader,
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$tbody,
						{
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html_Events$on,
								'click',
								A2(
									_elm_lang$core$Json_Decode$map,
									_elm_lang$core$Date$fromTime,
									A2(
										_elm_lang$core$Json_Decode$at,
										{
											ctor: '::',
											_0: 'target',
											_1: {
												ctor: '::',
												_0: 'time',
												_1: {ctor: '[]'}
											}
										},
										_elm_lang$core$Json_Decode$float))),
							_1: {ctor: '[]'}
						},
						A2(
							_elm_lang$core$List$map,
							function (week) {
								return A2(
									_elm_lang$html$Html$tr,
									{ctor: '[]'},
									A2(
										_elm_lang$core$List$map,
										function (date) {
											var state = A3(_justinmimbs$elm_date_extra$Date_Extra$equalBy, _justinmimbs$elm_date_extra$Date_Extra$Day, date, selected) ? _justinmimbs$elm_date_selector$DateSelector$Selected : (((!A3(_justinmimbs$elm_date_extra$Date_Extra$isBetween, minimum, maximum, date)) || isInvertedMinMax) ? _justinmimbs$elm_date_selector$DateSelector$Disabled : ((!_elm_lang$core$Native_Utils.eq(
												_elm_lang$core$Date$month(date),
												_elm_lang$core$Date$month(selected))) ? _justinmimbs$elm_date_selector$DateSelector$Dimmed : _justinmimbs$elm_date_selector$DateSelector$Normal));
											return A2(
												_elm_lang$html$Html$td,
												{
													ctor: '::',
													_0: _elm_lang$html$Html_Attributes$class(
														_justinmimbs$elm_date_selector$DateSelector$classNameFromState(state)),
													_1: {
														ctor: '::',
														_0: A2(
															_elm_lang$html$Html_Attributes$property,
															'time',
															_justinmimbs$elm_date_selector$DateSelector$isSelectable(state) ? _elm_lang$core$Json_Encode$float(
																_elm_lang$core$Date$toTime(date)) : _elm_lang$core$Json_Encode$null),
														_1: {ctor: '[]'}
													}
												},
												{
													ctor: '::',
													_0: _elm_lang$html$Html$text(
														_elm_lang$core$Basics$toString(
															_elm_lang$core$Date$day(date))),
													_1: {ctor: '[]'}
												});
										},
										week));
							},
							weeks)),
					_1: {ctor: '[]'}
				}
			});
	});
var _justinmimbs$elm_date_selector$DateSelector$view = F3(
	function (minimum, maximum, maybeSelected) {
		return A2(
			_elm_lang$html$Html$map,
			A2(_justinmimbs$elm_date_extra$Date_Extra$clamp, minimum, maximum),
			A2(
				_elm_lang$html$Html$div,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$classList(
						{
							ctor: '::',
							_0: {ctor: '_Tuple2', _0: 'date-selector', _1: true},
							_1: {
								ctor: '::',
								_0: {
									ctor: '_Tuple2',
									_0: 'date-selector--scrollable-year',
									_1: _elm_lang$core$Native_Utils.cmp(
										_elm_lang$core$Date$year(maximum) - _elm_lang$core$Date$year(minimum),
										12) > -1
								},
								_1: {ctor: '[]'}
							}
						}),
					_1: {ctor: '[]'}
				},
				{
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$div,
						{ctor: '[]'},
						{
							ctor: '::',
							_0: A3(_justinmimbs$elm_date_selector$DateSelector$viewYearList, minimum, maximum, maybeSelected),
							_1: {ctor: '[]'}
						}),
					_1: {
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$div,
							{ctor: '[]'},
							{
								ctor: '::',
								_0: A2(
									_elm_lang$core$Maybe$withDefault,
									_justinmimbs$elm_date_selector$DateSelector$viewMonthListDisabled,
									A2(
										_elm_lang$core$Maybe$map,
										A2(_justinmimbs$elm_date_selector$DateSelector$viewMonthList, minimum, maximum),
										maybeSelected)),
								_1: {ctor: '[]'}
							}),
						_1: {
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$div,
								{ctor: '[]'},
								{
									ctor: '::',
									_0: function () {
										var _p3 = maybeSelected;
										if (_p3.ctor === 'Just') {
											return A3(_justinmimbs$elm_date_selector$DateSelector$viewDateTable, minimum, maximum, _p3._0);
										} else {
											return _justinmimbs$elm_date_selector$DateSelector$viewDateTableDisabled(minimum);
										}
									}(),
									_1: {ctor: '[]'}
								}),
							_1: {ctor: '[]'}
						}
					}
				}));
	});

var _krisajenkins$formatting$Formatting$html = function (_p0) {
	var _p1 = _p0;
	return _p1._0(_elm_lang$html$Html$text);
};
var _krisajenkins$formatting$Formatting$print = function (_p2) {
	var _p3 = _p2;
	return _p3._0(_elm_lang$core$Basics$identity);
};
var _krisajenkins$formatting$Formatting$Format = function (a) {
	return {ctor: 'Format', _0: a};
};
var _krisajenkins$formatting$Formatting$compose = F2(
	function (_p5, _p4) {
		var _p6 = _p5;
		var _p7 = _p4;
		return _krisajenkins$formatting$Formatting$Format(
			function (callback) {
				return _p6._0(
					function (strF) {
						return _p7._0(
							function (strG) {
								return callback(
									A2(_elm_lang$core$Basics_ops['++'], strF, strG));
							});
					});
			});
	});
var _krisajenkins$formatting$Formatting_ops = _krisajenkins$formatting$Formatting_ops || {};
_krisajenkins$formatting$Formatting_ops['<>'] = _krisajenkins$formatting$Formatting$compose;
var _krisajenkins$formatting$Formatting$map = F2(
	function (f, _p8) {
		var _p9 = _p8;
		return _krisajenkins$formatting$Formatting$Format(
			function (callback) {
				return _p9._0(
					function (_p10) {
						return callback(
							f(_p10));
					});
			});
	});
var _krisajenkins$formatting$Formatting$pad = F2(
	function (n, $char) {
		return _krisajenkins$formatting$Formatting$map(
			A2(_elm_lang$core$String$pad, n, $char));
	});
var _krisajenkins$formatting$Formatting$padLeft = F2(
	function (n, $char) {
		return _krisajenkins$formatting$Formatting$map(
			A2(_elm_lang$core$String$padLeft, n, $char));
	});
var _krisajenkins$formatting$Formatting$padRight = F2(
	function (n, $char) {
		return _krisajenkins$formatting$Formatting$map(
			A2(_elm_lang$core$String$padRight, n, $char));
	});
var _krisajenkins$formatting$Formatting$premap = F2(
	function (f, _p11) {
		var _p12 = _p11;
		return _krisajenkins$formatting$Formatting$Format(
			function (callback) {
				return function (_p13) {
					return A2(
						_p12._0,
						callback,
						f(_p13));
				};
			});
	});
var _krisajenkins$formatting$Formatting$apply = F2(
	function (_p14, value) {
		var _p15 = _p14;
		return _krisajenkins$formatting$Formatting$Format(
			function (callback) {
				return A2(_p15._0, callback, value);
			});
	});
var _krisajenkins$formatting$Formatting$s = function (str) {
	return _krisajenkins$formatting$Formatting$Format(
		function (c) {
			return c(str);
		});
};
var _krisajenkins$formatting$Formatting$wrap = F2(
	function (wrapping, format) {
		return A2(
			_krisajenkins$formatting$Formatting_ops['<>'],
			_krisajenkins$formatting$Formatting$s(wrapping),
			A2(
				_krisajenkins$formatting$Formatting_ops['<>'],
				format,
				_krisajenkins$formatting$Formatting$s(wrapping)));
	});
var _krisajenkins$formatting$Formatting$string = _krisajenkins$formatting$Formatting$Format(_elm_lang$core$Basics$identity);
var _krisajenkins$formatting$Formatting$uriFragment = A2(_krisajenkins$formatting$Formatting$premap, _elm_lang$http$Http$encodeUri, _krisajenkins$formatting$Formatting$string);
var _krisajenkins$formatting$Formatting$any = _krisajenkins$formatting$Formatting$Format(
	function (c) {
		return function (_p16) {
			return c(
				_elm_lang$core$Basics$toString(_p16));
		};
	});
var _krisajenkins$formatting$Formatting$int = _krisajenkins$formatting$Formatting$any;
var _krisajenkins$formatting$Formatting$bool = _krisajenkins$formatting$Formatting$any;
var _krisajenkins$formatting$Formatting$float = _krisajenkins$formatting$Formatting$any;
var _krisajenkins$formatting$Formatting$roundTo = function (n) {
	return _krisajenkins$formatting$Formatting$Format(
		F2(
			function (callback, value) {
				return callback(
					function () {
						if (_elm_lang$core$Native_Utils.eq(n, 0)) {
							return _elm_lang$core$Basics$toString(
								_elm_lang$core$Basics$round(value));
						} else {
							var finalFormat = A2(
								_krisajenkins$formatting$Formatting_ops['<>'],
								_krisajenkins$formatting$Formatting$int,
								A2(
									_krisajenkins$formatting$Formatting_ops['<>'],
									_krisajenkins$formatting$Formatting$s('.'),
									A3(
										_krisajenkins$formatting$Formatting$padLeft,
										n,
										_elm_lang$core$Native_Utils.chr('0'),
										_krisajenkins$formatting$Formatting$int)));
							var exp = Math.pow(10, n);
							var raised = _elm_lang$core$Basics$round(
								value * _elm_lang$core$Basics$toFloat(exp));
							return A3(
								_krisajenkins$formatting$Formatting$print,
								finalFormat,
								(raised / exp) | 0,
								A2(
									_elm_lang$core$Basics$rem,
									_elm_lang$core$Basics$abs(raised),
									exp));
						}
					}());
			}));
};
var _krisajenkins$formatting$Formatting$dp = _krisajenkins$formatting$Formatting$roundTo;

var _mdgriffith$elm_style_animation$Animation_Model$matchPoints = F2(
	function (points1, points2) {
		var diff = _elm_lang$core$List$length(points1) - _elm_lang$core$List$length(points2);
		if (_elm_lang$core$Native_Utils.cmp(diff, 0) > 0) {
			var _p0 = _elm_lang$core$List$head(
				_elm_lang$core$List$reverse(points2));
			if (_p0.ctor === 'Nothing') {
				return {ctor: '_Tuple2', _0: points1, _1: points2};
			} else {
				return {
					ctor: '_Tuple2',
					_0: points1,
					_1: A2(
						_elm_lang$core$Basics_ops['++'],
						points2,
						A2(
							_elm_lang$core$List$repeat,
							_elm_lang$core$Basics$abs(diff),
							_p0._0))
				};
			}
		} else {
			if (_elm_lang$core$Native_Utils.cmp(diff, 0) < 0) {
				var _p1 = _elm_lang$core$List$head(
					_elm_lang$core$List$reverse(points1));
				if (_p1.ctor === 'Nothing') {
					return {ctor: '_Tuple2', _0: points1, _1: points2};
				} else {
					return {
						ctor: '_Tuple2',
						_0: A2(
							_elm_lang$core$Basics_ops['++'],
							points1,
							A2(
								_elm_lang$core$List$repeat,
								_elm_lang$core$Basics$abs(diff),
								_p1._0)),
						_1: points2
					};
				}
			} else {
				return {ctor: '_Tuple2', _0: points1, _1: points2};
			}
		}
	});
var _mdgriffith$elm_style_animation$Animation_Model$vTolerance = 0.1;
var _mdgriffith$elm_style_animation$Animation_Model$tolerance = 1.0e-2;
var _mdgriffith$elm_style_animation$Animation_Model$isCmdDone = function (cmd) {
	var motionDone = function (motion) {
		return _elm_lang$core$Native_Utils.eq(motion.velocity, 0) && _elm_lang$core$Native_Utils.eq(motion.position, motion.target);
	};
	var _p2 = cmd;
	switch (_p2.ctor) {
		case 'Move':
			return motionDone(_p2._0) && motionDone(_p2._1);
		case 'MoveTo':
			return motionDone(_p2._0) && motionDone(_p2._1);
		case 'Line':
			return motionDone(_p2._0) && motionDone(_p2._1);
		case 'LineTo':
			return motionDone(_p2._0) && motionDone(_p2._1);
		case 'Horizontal':
			return motionDone(_p2._0);
		case 'HorizontalTo':
			return motionDone(_p2._0);
		case 'Vertical':
			return motionDone(_p2._0);
		case 'VerticalTo':
			return motionDone(_p2._0);
		case 'Curve':
			var _p5 = _p2._0.point;
			var _p4 = _p2._0.control2;
			var _p3 = _p2._0.control1;
			return motionDone(
				_elm_lang$core$Tuple$first(_p3)) && (motionDone(
				_elm_lang$core$Tuple$second(_p3)) && (motionDone(
				_elm_lang$core$Tuple$first(_p4)) && (motionDone(
				_elm_lang$core$Tuple$second(_p4)) && (motionDone(
				_elm_lang$core$Tuple$first(_p5)) && motionDone(
				_elm_lang$core$Tuple$second(_p5))))));
		case 'CurveTo':
			var _p8 = _p2._0.point;
			var _p7 = _p2._0.control2;
			var _p6 = _p2._0.control1;
			return motionDone(
				_elm_lang$core$Tuple$first(_p6)) && (motionDone(
				_elm_lang$core$Tuple$second(_p6)) && (motionDone(
				_elm_lang$core$Tuple$first(_p7)) && (motionDone(
				_elm_lang$core$Tuple$second(_p7)) && (motionDone(
				_elm_lang$core$Tuple$first(_p8)) && motionDone(
				_elm_lang$core$Tuple$second(_p8))))));
		case 'Quadratic':
			var _p10 = _p2._0.point;
			var _p9 = _p2._0.control;
			return motionDone(
				_elm_lang$core$Tuple$first(_p9)) && (motionDone(
				_elm_lang$core$Tuple$second(_p9)) && (motionDone(
				_elm_lang$core$Tuple$first(_p10)) && motionDone(
				_elm_lang$core$Tuple$second(_p10))));
		case 'QuadraticTo':
			var _p12 = _p2._0.point;
			var _p11 = _p2._0.control;
			return motionDone(
				_elm_lang$core$Tuple$first(_p11)) && (motionDone(
				_elm_lang$core$Tuple$second(_p11)) && (motionDone(
				_elm_lang$core$Tuple$first(_p12)) && motionDone(
				_elm_lang$core$Tuple$second(_p12))));
		case 'SmoothQuadratic':
			return A2(
				_elm_lang$core$List$all,
				function (_p13) {
					var _p14 = _p13;
					return motionDone(_p14._0) && motionDone(_p14._1);
				},
				_p2._0);
		case 'SmoothQuadraticTo':
			return A2(
				_elm_lang$core$List$all,
				function (_p15) {
					var _p16 = _p15;
					return motionDone(_p16._0) && motionDone(_p16._1);
				},
				_p2._0);
		case 'Smooth':
			return A2(
				_elm_lang$core$List$all,
				function (_p17) {
					var _p18 = _p17;
					return motionDone(_p18._0) && motionDone(_p18._1);
				},
				_p2._0);
		case 'SmoothTo':
			return A2(
				_elm_lang$core$List$all,
				function (_p19) {
					var _p20 = _p19;
					return motionDone(_p20._0) && motionDone(_p20._1);
				},
				_p2._0);
		case 'ClockwiseArc':
			var _p21 = _p2._0;
			return motionDone(_p21.x) && (motionDone(_p21.y) && (motionDone(_p21.radius) && (motionDone(_p21.startAngle) && motionDone(_p21.endAngle))));
		case 'AntiClockwiseArc':
			var _p22 = _p2._0;
			return motionDone(_p22.x) && (motionDone(_p22.y) && (motionDone(_p22.radius) && (motionDone(_p22.startAngle) && motionDone(_p22.endAngle))));
		default:
			return true;
	}
};
var _mdgriffith$elm_style_animation$Animation_Model$isDone = function (property) {
	var motionDone = function (motion) {
		var _p23 = motion.interpolation;
		switch (_p23.ctor) {
			case 'Spring':
				return _elm_lang$core$Native_Utils.eq(motion.velocity, 0) && _elm_lang$core$Native_Utils.eq(motion.position, motion.target);
			case 'Easing':
				return _elm_lang$core$Native_Utils.eq(_p23._0.progress, 1);
			default:
				return _elm_lang$core$Native_Utils.eq(motion.position, motion.target);
		}
	};
	var _p24 = property;
	switch (_p24.ctor) {
		case 'ExactProperty':
			return true;
		case 'ColorProperty':
			return A2(
				_elm_lang$core$List$all,
				motionDone,
				{
					ctor: '::',
					_0: _p24._1,
					_1: {
						ctor: '::',
						_0: _p24._2,
						_1: {
							ctor: '::',
							_0: _p24._3,
							_1: {
								ctor: '::',
								_0: _p24._4,
								_1: {ctor: '[]'}
							}
						}
					}
				});
		case 'ShadowProperty':
			var _p25 = _p24._2;
			return A2(
				_elm_lang$core$List$all,
				motionDone,
				{
					ctor: '::',
					_0: _p25.offsetX,
					_1: {
						ctor: '::',
						_0: _p25.offsetY,
						_1: {
							ctor: '::',
							_0: _p25.size,
							_1: {
								ctor: '::',
								_0: _p25.blur,
								_1: {
									ctor: '::',
									_0: _p25.red,
									_1: {
										ctor: '::',
										_0: _p25.green,
										_1: {
											ctor: '::',
											_0: _p25.blue,
											_1: {
												ctor: '::',
												_0: _p25.alpha,
												_1: {ctor: '[]'}
											}
										}
									}
								}
							}
						}
					}
				});
		case 'Property':
			return motionDone(_p24._1);
		case 'Property2':
			return motionDone(_p24._1) && motionDone(_p24._2);
		case 'Property3':
			return A2(
				_elm_lang$core$List$all,
				motionDone,
				{
					ctor: '::',
					_0: _p24._1,
					_1: {
						ctor: '::',
						_0: _p24._2,
						_1: {
							ctor: '::',
							_0: _p24._3,
							_1: {ctor: '[]'}
						}
					}
				});
		case 'Property4':
			return A2(
				_elm_lang$core$List$all,
				motionDone,
				{
					ctor: '::',
					_0: _p24._1,
					_1: {
						ctor: '::',
						_0: _p24._2,
						_1: {
							ctor: '::',
							_0: _p24._3,
							_1: {
								ctor: '::',
								_0: _p24._4,
								_1: {ctor: '[]'}
							}
						}
					}
				});
		case 'AngleProperty':
			return motionDone(_p24._1);
		case 'Points':
			return A2(
				_elm_lang$core$List$all,
				function (_p26) {
					var _p27 = _p26;
					return motionDone(_p27._0) && motionDone(_p27._1);
				},
				_p24._0);
		default:
			return A2(_elm_lang$core$List$all, _mdgriffith$elm_style_animation$Animation_Model$isCmdDone, _p24._0);
	}
};
var _mdgriffith$elm_style_animation$Animation_Model$refreshTiming = F2(
	function (now, timing) {
		var dt = now - timing.current;
		return {
			current: now,
			dt: ((_elm_lang$core$Native_Utils.cmp(dt, 34) > 0) || _elm_lang$core$Native_Utils.eq(timing.current, 0)) ? 16.666 : dt
		};
	});
var _mdgriffith$elm_style_animation$Animation_Model$propertyName = function (prop) {
	var _p28 = prop;
	switch (_p28.ctor) {
		case 'ExactProperty':
			return _p28._0;
		case 'ColorProperty':
			return _p28._0;
		case 'ShadowProperty':
			return _p28._0;
		case 'Property':
			return _p28._0;
		case 'Property2':
			return _p28._0;
		case 'Property3':
			return _p28._0;
		case 'Property4':
			return _p28._0;
		case 'AngleProperty':
			return _p28._0;
		case 'Points':
			return 'points';
		default:
			return 'path';
	}
};
var _mdgriffith$elm_style_animation$Animation_Model$replaceProps = F2(
	function (props, replacements) {
		var replacementNames = A2(_elm_lang$core$List$map, _mdgriffith$elm_style_animation$Animation_Model$propertyName, replacements);
		var removed = A2(
			_elm_lang$core$List$filter,
			function (prop) {
				return !A2(
					_elm_lang$core$List$member,
					_mdgriffith$elm_style_animation$Animation_Model$propertyName(prop),
					replacementNames);
			},
			props);
		return A2(_elm_lang$core$Basics_ops['++'], removed, replacements);
	});
var _mdgriffith$elm_style_animation$Animation_Model$zipPropertiesGreedy = F2(
	function (initialProps, newTargetProps) {
		var propertyMatch = F2(
			function (prop1, prop2) {
				return _elm_lang$core$Native_Utils.eq(
					_mdgriffith$elm_style_animation$Animation_Model$propertyName(prop1),
					_mdgriffith$elm_style_animation$Animation_Model$propertyName(prop2));
			});
		var _p29 = A3(
			_elm_lang$core$List$foldl,
			F2(
				function (_p31, _p30) {
					var _p32 = _p30;
					var _p39 = _p32._1;
					var _p38 = _p32._0;
					var _p37 = _p32._2;
					var _p33 = _elm_lang$core$List$head(_p38);
					if (_p33.ctor === 'Nothing') {
						return {ctor: '_Tuple3', _0: _p38, _1: _p39, _2: _p37};
					} else {
						var _p36 = _p33._0;
						var _p34 = A2(
							_elm_lang$core$List$partition,
							propertyMatch(_p36),
							_p39);
						var matchingBs = _p34._0;
						var nonMatchingBs = _p34._1;
						return {
							ctor: '_Tuple3',
							_0: A2(_elm_lang$core$List$drop, 1, _p38),
							_1: function () {
								var _p35 = matchingBs;
								if (_p35.ctor === '[]') {
									return nonMatchingBs;
								} else {
									return A2(_elm_lang$core$Basics_ops['++'], _p35._1, nonMatchingBs);
								}
							}(),
							_2: {
								ctor: '::',
								_0: {
									ctor: '_Tuple2',
									_0: _p36,
									_1: _elm_lang$core$List$head(matchingBs)
								},
								_1: _p37
							}
						};
					}
				}),
			{
				ctor: '_Tuple3',
				_0: initialProps,
				_1: newTargetProps,
				_2: {ctor: '[]'}
			},
			A2(
				_elm_lang$core$List$repeat,
				_elm_lang$core$List$length(initialProps),
				0));
		var warnings = _p29._1;
		var props = _p29._2;
		var _p40 = A2(
			_elm_lang$core$List$map,
			function (b) {
				return A2(
					_elm_lang$core$Debug$log,
					'elm-style-animation',
					A2(
						_elm_lang$core$Basics_ops['++'],
						_mdgriffith$elm_style_animation$Animation_Model$propertyName(b),
						' has no initial value and therefore will not be animated.'));
			},
			warnings);
		return _elm_lang$core$List$reverse(props);
	});
var _mdgriffith$elm_style_animation$Animation_Model$Timing = F2(
	function (a, b) {
		return {current: a, dt: b};
	});
var _mdgriffith$elm_style_animation$Animation_Model$Motion = F6(
	function (a, b, c, d, e, f) {
		return {position: a, velocity: b, target: c, interpolation: d, unit: e, interpolationOverride: f};
	});
var _mdgriffith$elm_style_animation$Animation_Model$ShadowMotion = F8(
	function (a, b, c, d, e, f, g, h) {
		return {offsetX: a, offsetY: b, size: c, blur: d, red: e, green: f, blue: g, alpha: h};
	});
var _mdgriffith$elm_style_animation$Animation_Model$CubicCurveMotion = F3(
	function (a, b, c) {
		return {control1: a, control2: b, point: c};
	});
var _mdgriffith$elm_style_animation$Animation_Model$QuadraticCurveMotion = F2(
	function (a, b) {
		return {control: a, point: b};
	});
var _mdgriffith$elm_style_animation$Animation_Model$ArcMotion = F5(
	function (a, b, c, d, e) {
		return {x: a, y: b, radius: c, startAngle: d, endAngle: e};
	});
var _mdgriffith$elm_style_animation$Animation_Model$Animation = function (a) {
	return {ctor: 'Animation', _0: a};
};
var _mdgriffith$elm_style_animation$Animation_Model$Tick = function (a) {
	return {ctor: 'Tick', _0: a};
};
var _mdgriffith$elm_style_animation$Animation_Model$Loop = function (a) {
	return {ctor: 'Loop', _0: a};
};
var _mdgriffith$elm_style_animation$Animation_Model$Repeat = F2(
	function (a, b) {
		return {ctor: 'Repeat', _0: a, _1: b};
	});
var _mdgriffith$elm_style_animation$Animation_Model$Send = function (a) {
	return {ctor: 'Send', _0: a};
};
var _mdgriffith$elm_style_animation$Animation_Model$Wait = function (a) {
	return {ctor: 'Wait', _0: a};
};
var _mdgriffith$elm_style_animation$Animation_Model$Set = function (a) {
	return {ctor: 'Set', _0: a};
};
var _mdgriffith$elm_style_animation$Animation_Model$ToWith = function (a) {
	return {ctor: 'ToWith', _0: a};
};
var _mdgriffith$elm_style_animation$Animation_Model$To = function (a) {
	return {ctor: 'To', _0: a};
};
var _mdgriffith$elm_style_animation$Animation_Model$Step = {ctor: 'Step'};
var _mdgriffith$elm_style_animation$Animation_Model$AtSpeed = function (a) {
	return {ctor: 'AtSpeed', _0: a};
};
var _mdgriffith$elm_style_animation$Animation_Model$Easing = function (a) {
	return {ctor: 'Easing', _0: a};
};
var _mdgriffith$elm_style_animation$Animation_Model$stepInterpolation = F2(
	function (dtms, motion) {
		var interpolationToUse = A2(_elm_lang$core$Maybe$withDefault, motion.interpolation, motion.interpolationOverride);
		var _p41 = interpolationToUse;
		switch (_p41.ctor) {
			case 'AtSpeed':
				var _p43 = _p41._0.perSecond;
				var _p42 = function () {
					if (_elm_lang$core$Native_Utils.cmp(motion.position, motion.target) < 0) {
						var $new = motion.position + (_p43 * (dtms / 1000));
						return {
							ctor: '_Tuple2',
							_0: $new,
							_1: _elm_lang$core$Native_Utils.cmp($new, motion.target) > -1
						};
					} else {
						var $new = motion.position - (_p43 * (dtms / 1000));
						return {
							ctor: '_Tuple2',
							_0: $new,
							_1: _elm_lang$core$Native_Utils.cmp($new, motion.target) < 1
						};
					}
				}();
				var newPos = _p42._0;
				var finished = _p42._1;
				return finished ? _elm_lang$core$Native_Utils.update(
					motion,
					{position: motion.target, velocity: 0.0}) : _elm_lang$core$Native_Utils.update(
					motion,
					{position: newPos, velocity: _p43 * 1000});
			case 'Spring':
				var fdamper = (-1 * _p41._0.damping) * motion.velocity;
				var fspring = _p41._0.stiffness * (motion.target - motion.position);
				var a = fspring + fdamper;
				var dt = dtms / 1000;
				var newVelocity = motion.velocity + (a * dt);
				var newPos = motion.position + (newVelocity * dt);
				var dx = _elm_lang$core$Basics$abs(motion.target - newPos);
				return ((_elm_lang$core$Native_Utils.cmp(dx, _mdgriffith$elm_style_animation$Animation_Model$tolerance) < 0) && (_elm_lang$core$Native_Utils.cmp(
					_elm_lang$core$Basics$abs(newVelocity),
					_mdgriffith$elm_style_animation$Animation_Model$vTolerance) < 0)) ? _elm_lang$core$Native_Utils.update(
					motion,
					{position: motion.target, velocity: 0.0}) : _elm_lang$core$Native_Utils.update(
					motion,
					{position: newPos, velocity: newVelocity});
			default:
				var _p48 = _p41._0.start;
				var _p47 = _p41._0.progress;
				var _p46 = _p41._0.ease;
				var _p45 = _p41._0.duration;
				var distance = motion.target - _p48;
				var newProgress = (_elm_lang$core$Native_Utils.cmp((dtms / _p45) + _p47, 1) < 0) ? ((dtms / _p45) + _p47) : 1;
				var eased = _p46(newProgress);
				var newPos = (eased * distance) + _p48;
				var newVelocity = _elm_lang$core$Native_Utils.eq(newProgress, 1) ? 0 : ((newPos - motion.position) / dtms);
				var _p44 = motion.interpolationOverride;
				if (_p44.ctor === 'Nothing') {
					return _elm_lang$core$Native_Utils.update(
						motion,
						{
							position: newPos,
							velocity: newVelocity,
							interpolation: _mdgriffith$elm_style_animation$Animation_Model$Easing(
								{progress: newProgress, duration: _p45, ease: _p46, start: _p48})
						});
				} else {
					return _elm_lang$core$Native_Utils.update(
						motion,
						{
							position: newPos,
							velocity: newVelocity,
							interpolationOverride: _elm_lang$core$Maybe$Just(
								_mdgriffith$elm_style_animation$Animation_Model$Easing(
									{progress: newProgress, duration: _p45, ease: _p46, start: _p48}))
						});
				}
		}
	});
var _mdgriffith$elm_style_animation$Animation_Model$Spring = function (a) {
	return {ctor: 'Spring', _0: a};
};
var _mdgriffith$elm_style_animation$Animation_Model$Path = function (a) {
	return {ctor: 'Path', _0: a};
};
var _mdgriffith$elm_style_animation$Animation_Model$Points = function (a) {
	return {ctor: 'Points', _0: a};
};
var _mdgriffith$elm_style_animation$Animation_Model$AngleProperty = F2(
	function (a, b) {
		return {ctor: 'AngleProperty', _0: a, _1: b};
	});
var _mdgriffith$elm_style_animation$Animation_Model$Property4 = F5(
	function (a, b, c, d, e) {
		return {ctor: 'Property4', _0: a, _1: b, _2: c, _3: d, _4: e};
	});
var _mdgriffith$elm_style_animation$Animation_Model$Property3 = F4(
	function (a, b, c, d) {
		return {ctor: 'Property3', _0: a, _1: b, _2: c, _3: d};
	});
var _mdgriffith$elm_style_animation$Animation_Model$Property2 = F3(
	function (a, b, c) {
		return {ctor: 'Property2', _0: a, _1: b, _2: c};
	});
var _mdgriffith$elm_style_animation$Animation_Model$Property = F2(
	function (a, b) {
		return {ctor: 'Property', _0: a, _1: b};
	});
var _mdgriffith$elm_style_animation$Animation_Model$ShadowProperty = F3(
	function (a, b, c) {
		return {ctor: 'ShadowProperty', _0: a, _1: b, _2: c};
	});
var _mdgriffith$elm_style_animation$Animation_Model$ColorProperty = F5(
	function (a, b, c, d, e) {
		return {ctor: 'ColorProperty', _0: a, _1: b, _2: c, _3: d, _4: e};
	});
var _mdgriffith$elm_style_animation$Animation_Model$ExactProperty = F2(
	function (a, b) {
		return {ctor: 'ExactProperty', _0: a, _1: b};
	});
var _mdgriffith$elm_style_animation$Animation_Model$Close = {ctor: 'Close'};
var _mdgriffith$elm_style_animation$Animation_Model$AntiClockwiseArc = function (a) {
	return {ctor: 'AntiClockwiseArc', _0: a};
};
var _mdgriffith$elm_style_animation$Animation_Model$ClockwiseArc = function (a) {
	return {ctor: 'ClockwiseArc', _0: a};
};
var _mdgriffith$elm_style_animation$Animation_Model$SmoothTo = function (a) {
	return {ctor: 'SmoothTo', _0: a};
};
var _mdgriffith$elm_style_animation$Animation_Model$Smooth = function (a) {
	return {ctor: 'Smooth', _0: a};
};
var _mdgriffith$elm_style_animation$Animation_Model$SmoothQuadraticTo = function (a) {
	return {ctor: 'SmoothQuadraticTo', _0: a};
};
var _mdgriffith$elm_style_animation$Animation_Model$SmoothQuadratic = function (a) {
	return {ctor: 'SmoothQuadratic', _0: a};
};
var _mdgriffith$elm_style_animation$Animation_Model$QuadraticTo = function (a) {
	return {ctor: 'QuadraticTo', _0: a};
};
var _mdgriffith$elm_style_animation$Animation_Model$Quadratic = function (a) {
	return {ctor: 'Quadratic', _0: a};
};
var _mdgriffith$elm_style_animation$Animation_Model$CurveTo = function (a) {
	return {ctor: 'CurveTo', _0: a};
};
var _mdgriffith$elm_style_animation$Animation_Model$Curve = function (a) {
	return {ctor: 'Curve', _0: a};
};
var _mdgriffith$elm_style_animation$Animation_Model$VerticalTo = function (a) {
	return {ctor: 'VerticalTo', _0: a};
};
var _mdgriffith$elm_style_animation$Animation_Model$Vertical = function (a) {
	return {ctor: 'Vertical', _0: a};
};
var _mdgriffith$elm_style_animation$Animation_Model$HorizontalTo = function (a) {
	return {ctor: 'HorizontalTo', _0: a};
};
var _mdgriffith$elm_style_animation$Animation_Model$Horizontal = function (a) {
	return {ctor: 'Horizontal', _0: a};
};
var _mdgriffith$elm_style_animation$Animation_Model$LineTo = F2(
	function (a, b) {
		return {ctor: 'LineTo', _0: a, _1: b};
	});
var _mdgriffith$elm_style_animation$Animation_Model$Line = F2(
	function (a, b) {
		return {ctor: 'Line', _0: a, _1: b};
	});
var _mdgriffith$elm_style_animation$Animation_Model$MoveTo = F2(
	function (a, b) {
		return {ctor: 'MoveTo', _0: a, _1: b};
	});
var _mdgriffith$elm_style_animation$Animation_Model$Move = F2(
	function (a, b) {
		return {ctor: 'Move', _0: a, _1: b};
	});
var _mdgriffith$elm_style_animation$Animation_Model$mapPathMotion = F2(
	function (fn, cmd) {
		var mapCoords = function (coords) {
			return A2(
				_elm_lang$core$List$map,
				function (_p49) {
					var _p50 = _p49;
					return {
						ctor: '_Tuple2',
						_0: fn(_p50._0),
						_1: fn(_p50._1)
					};
				},
				coords);
		};
		var _p51 = cmd;
		switch (_p51.ctor) {
			case 'Move':
				return A2(
					_mdgriffith$elm_style_animation$Animation_Model$Move,
					fn(_p51._0),
					fn(_p51._1));
			case 'MoveTo':
				return A2(
					_mdgriffith$elm_style_animation$Animation_Model$MoveTo,
					fn(_p51._0),
					fn(_p51._1));
			case 'Line':
				return A2(
					_mdgriffith$elm_style_animation$Animation_Model$Line,
					fn(_p51._0),
					fn(_p51._1));
			case 'LineTo':
				return A2(
					_mdgriffith$elm_style_animation$Animation_Model$LineTo,
					fn(_p51._0),
					fn(_p51._1));
			case 'Horizontal':
				return _mdgriffith$elm_style_animation$Animation_Model$Horizontal(
					fn(_p51._0));
			case 'HorizontalTo':
				return _mdgriffith$elm_style_animation$Animation_Model$HorizontalTo(
					fn(_p51._0));
			case 'Vertical':
				return _mdgriffith$elm_style_animation$Animation_Model$Vertical(
					fn(_p51._0));
			case 'VerticalTo':
				return _mdgriffith$elm_style_animation$Animation_Model$VerticalTo(
					fn(_p51._0));
			case 'Curve':
				var _p54 = _p51._0.point;
				var _p53 = _p51._0.control2;
				var _p52 = _p51._0.control1;
				return _mdgriffith$elm_style_animation$Animation_Model$Curve(
					{
						control1: {
							ctor: '_Tuple2',
							_0: fn(
								_elm_lang$core$Tuple$first(_p52)),
							_1: fn(
								_elm_lang$core$Tuple$second(_p52))
						},
						control2: {
							ctor: '_Tuple2',
							_0: fn(
								_elm_lang$core$Tuple$first(_p53)),
							_1: fn(
								_elm_lang$core$Tuple$second(_p53))
						},
						point: {
							ctor: '_Tuple2',
							_0: fn(
								_elm_lang$core$Tuple$first(_p54)),
							_1: fn(
								_elm_lang$core$Tuple$second(_p54))
						}
					});
			case 'CurveTo':
				var _p57 = _p51._0.point;
				var _p56 = _p51._0.control2;
				var _p55 = _p51._0.control1;
				return _mdgriffith$elm_style_animation$Animation_Model$CurveTo(
					{
						control1: {
							ctor: '_Tuple2',
							_0: fn(
								_elm_lang$core$Tuple$first(_p55)),
							_1: fn(
								_elm_lang$core$Tuple$second(_p55))
						},
						control2: {
							ctor: '_Tuple2',
							_0: fn(
								_elm_lang$core$Tuple$first(_p56)),
							_1: fn(
								_elm_lang$core$Tuple$second(_p56))
						},
						point: {
							ctor: '_Tuple2',
							_0: fn(
								_elm_lang$core$Tuple$first(_p57)),
							_1: fn(
								_elm_lang$core$Tuple$second(_p57))
						}
					});
			case 'Quadratic':
				var _p59 = _p51._0.point;
				var _p58 = _p51._0.control;
				return _mdgriffith$elm_style_animation$Animation_Model$Quadratic(
					{
						control: {
							ctor: '_Tuple2',
							_0: fn(
								_elm_lang$core$Tuple$first(_p58)),
							_1: fn(
								_elm_lang$core$Tuple$second(_p58))
						},
						point: {
							ctor: '_Tuple2',
							_0: fn(
								_elm_lang$core$Tuple$first(_p59)),
							_1: fn(
								_elm_lang$core$Tuple$second(_p59))
						}
					});
			case 'QuadraticTo':
				var _p61 = _p51._0.point;
				var _p60 = _p51._0.control;
				return _mdgriffith$elm_style_animation$Animation_Model$QuadraticTo(
					{
						control: {
							ctor: '_Tuple2',
							_0: fn(
								_elm_lang$core$Tuple$first(_p60)),
							_1: fn(
								_elm_lang$core$Tuple$second(_p60))
						},
						point: {
							ctor: '_Tuple2',
							_0: fn(
								_elm_lang$core$Tuple$first(_p61)),
							_1: fn(
								_elm_lang$core$Tuple$second(_p61))
						}
					});
			case 'SmoothQuadratic':
				return _mdgriffith$elm_style_animation$Animation_Model$SmoothQuadratic(
					mapCoords(_p51._0));
			case 'SmoothQuadraticTo':
				return _mdgriffith$elm_style_animation$Animation_Model$SmoothQuadraticTo(
					mapCoords(_p51._0));
			case 'Smooth':
				return _mdgriffith$elm_style_animation$Animation_Model$Smooth(
					mapCoords(_p51._0));
			case 'SmoothTo':
				return _mdgriffith$elm_style_animation$Animation_Model$SmoothTo(
					mapCoords(_p51._0));
			case 'ClockwiseArc':
				var _p62 = _p51._0;
				return _mdgriffith$elm_style_animation$Animation_Model$ClockwiseArc(
					function () {
						var endAngle = _p62.endAngle;
						var startAngle = _p62.startAngle;
						var radius = _p62.radius;
						var y = _p62.y;
						var x = _p62.x;
						return _elm_lang$core$Native_Utils.update(
							_p62,
							{
								x: fn(x),
								y: fn(y),
								radius: fn(radius),
								startAngle: fn(startAngle),
								endAngle: fn(endAngle)
							});
					}());
			case 'AntiClockwiseArc':
				var _p63 = _p51._0;
				return _mdgriffith$elm_style_animation$Animation_Model$AntiClockwiseArc(
					function () {
						var endAngle = _p63.endAngle;
						var startAngle = _p63.startAngle;
						var radius = _p63.radius;
						var y = _p63.y;
						var x = _p63.x;
						return _elm_lang$core$Native_Utils.update(
							_p63,
							{
								x: fn(x),
								y: fn(y),
								radius: fn(radius),
								startAngle: fn(startAngle),
								endAngle: fn(endAngle)
							});
					}());
			default:
				return _mdgriffith$elm_style_animation$Animation_Model$Close;
		}
	});
var _mdgriffith$elm_style_animation$Animation_Model$mapToMotion = F2(
	function (fn, prop) {
		var _p64 = prop;
		switch (_p64.ctor) {
			case 'ExactProperty':
				return A2(_mdgriffith$elm_style_animation$Animation_Model$ExactProperty, _p64._0, _p64._1);
			case 'ColorProperty':
				return A5(
					_mdgriffith$elm_style_animation$Animation_Model$ColorProperty,
					_p64._0,
					fn(_p64._1),
					fn(_p64._2),
					fn(_p64._3),
					fn(_p64._4));
			case 'ShadowProperty':
				var _p65 = _p64._2;
				var alpha = _p65.alpha;
				var blue = _p65.blue;
				var green = _p65.green;
				var red = _p65.red;
				var blur = _p65.blur;
				var size = _p65.size;
				var offsetY = _p65.offsetY;
				var offsetX = _p65.offsetX;
				return A3(
					_mdgriffith$elm_style_animation$Animation_Model$ShadowProperty,
					_p64._0,
					_p64._1,
					{
						offsetX: fn(offsetX),
						offsetY: fn(offsetY),
						size: fn(size),
						blur: fn(blur),
						red: fn(red),
						green: fn(green),
						blue: fn(blue),
						alpha: fn(alpha)
					});
			case 'Property':
				return A2(
					_mdgriffith$elm_style_animation$Animation_Model$Property,
					_p64._0,
					fn(_p64._1));
			case 'Property2':
				return A3(
					_mdgriffith$elm_style_animation$Animation_Model$Property2,
					_p64._0,
					fn(_p64._1),
					fn(_p64._2));
			case 'Property3':
				return A4(
					_mdgriffith$elm_style_animation$Animation_Model$Property3,
					_p64._0,
					fn(_p64._1),
					fn(_p64._2),
					fn(_p64._3));
			case 'Property4':
				return A5(
					_mdgriffith$elm_style_animation$Animation_Model$Property4,
					_p64._0,
					fn(_p64._1),
					fn(_p64._2),
					fn(_p64._3),
					fn(_p64._4));
			case 'AngleProperty':
				return A2(
					_mdgriffith$elm_style_animation$Animation_Model$AngleProperty,
					_p64._0,
					fn(_p64._1));
			case 'Points':
				return _mdgriffith$elm_style_animation$Animation_Model$Points(
					A2(
						_elm_lang$core$List$map,
						function (_p66) {
							var _p67 = _p66;
							return {
								ctor: '_Tuple2',
								_0: fn(_p67._0),
								_1: fn(_p67._1)
							};
						},
						_p64._0));
			default:
				return _mdgriffith$elm_style_animation$Animation_Model$Path(
					A2(
						_elm_lang$core$List$map,
						_mdgriffith$elm_style_animation$Animation_Model$mapPathMotion(fn),
						_p64._0));
		}
	});
var _mdgriffith$elm_style_animation$Animation_Model$setPathTarget = F2(
	function (cmd, targetCmd) {
		var setMotionTarget = F2(
			function (motion, targetMotion) {
				var _p68 = motion.interpolation;
				if (_p68.ctor === 'Easing') {
					return _elm_lang$core$Native_Utils.update(
						motion,
						{
							target: targetMotion.position,
							interpolation: _mdgriffith$elm_style_animation$Animation_Model$Easing(
								_elm_lang$core$Native_Utils.update(
									_p68._0,
									{start: motion.position}))
						});
				} else {
					return _elm_lang$core$Native_Utils.update(
						motion,
						{target: targetMotion.position});
				}
			});
		var _p69 = cmd;
		switch (_p69.ctor) {
			case 'Move':
				var _p70 = targetCmd;
				if (_p70.ctor === 'Move') {
					return A2(
						_mdgriffith$elm_style_animation$Animation_Model$Move,
						A2(setMotionTarget, _p69._0, _p70._0),
						A2(setMotionTarget, _p69._1, _p70._1));
				} else {
					return cmd;
				}
			case 'MoveTo':
				var _p71 = targetCmd;
				if (_p71.ctor === 'MoveTo') {
					return A2(
						_mdgriffith$elm_style_animation$Animation_Model$MoveTo,
						A2(setMotionTarget, _p69._0, _p71._0),
						A2(setMotionTarget, _p69._1, _p71._1));
				} else {
					return cmd;
				}
			case 'Line':
				var _p72 = targetCmd;
				if (_p72.ctor === 'Line') {
					return A2(
						_mdgriffith$elm_style_animation$Animation_Model$Line,
						A2(setMotionTarget, _p69._0, _p72._0),
						A2(setMotionTarget, _p69._1, _p72._1));
				} else {
					return cmd;
				}
			case 'LineTo':
				var _p73 = targetCmd;
				if (_p73.ctor === 'LineTo') {
					return A2(
						_mdgriffith$elm_style_animation$Animation_Model$LineTo,
						A2(setMotionTarget, _p69._0, _p73._0),
						A2(setMotionTarget, _p69._1, _p73._1));
				} else {
					return cmd;
				}
			case 'Horizontal':
				var _p74 = targetCmd;
				if (_p74.ctor === 'Horizontal') {
					return _mdgriffith$elm_style_animation$Animation_Model$Horizontal(
						A2(setMotionTarget, _p69._0, _p74._0));
				} else {
					return cmd;
				}
			case 'HorizontalTo':
				var _p75 = targetCmd;
				if (_p75.ctor === 'HorizontalTo') {
					return _mdgriffith$elm_style_animation$Animation_Model$HorizontalTo(
						A2(setMotionTarget, _p69._0, _p75._0));
				} else {
					return cmd;
				}
			case 'Vertical':
				var _p76 = targetCmd;
				if (_p76.ctor === 'Vertical') {
					return _mdgriffith$elm_style_animation$Animation_Model$Vertical(
						A2(setMotionTarget, _p69._0, _p76._0));
				} else {
					return cmd;
				}
			case 'VerticalTo':
				var _p77 = targetCmd;
				if (_p77.ctor === 'VerticalTo') {
					return _mdgriffith$elm_style_animation$Animation_Model$VerticalTo(
						A2(setMotionTarget, _p69._0, _p77._0));
				} else {
					return cmd;
				}
			case 'Curve':
				var _p80 = _p69._0;
				var _p78 = targetCmd;
				if (_p78.ctor === 'Curve') {
					var _p79 = _p78._0;
					return _mdgriffith$elm_style_animation$Animation_Model$Curve(
						{
							control1: {
								ctor: '_Tuple2',
								_0: A2(
									setMotionTarget,
									_elm_lang$core$Tuple$first(_p80.control1),
									_elm_lang$core$Tuple$first(_p79.control1)),
								_1: A2(
									setMotionTarget,
									_elm_lang$core$Tuple$second(_p80.control1),
									_elm_lang$core$Tuple$second(_p79.control1))
							},
							control2: {
								ctor: '_Tuple2',
								_0: A2(
									setMotionTarget,
									_elm_lang$core$Tuple$first(_p80.control2),
									_elm_lang$core$Tuple$first(_p79.control2)),
								_1: A2(
									setMotionTarget,
									_elm_lang$core$Tuple$second(_p80.control2),
									_elm_lang$core$Tuple$second(_p79.control2))
							},
							point: {
								ctor: '_Tuple2',
								_0: A2(
									setMotionTarget,
									_elm_lang$core$Tuple$first(_p80.point),
									_elm_lang$core$Tuple$first(_p79.point)),
								_1: A2(
									setMotionTarget,
									_elm_lang$core$Tuple$second(_p80.point),
									_elm_lang$core$Tuple$second(_p79.point))
							}
						});
				} else {
					return cmd;
				}
			case 'CurveTo':
				var _p83 = _p69._0;
				var _p81 = targetCmd;
				if (_p81.ctor === 'CurveTo') {
					var _p82 = _p81._0;
					return _mdgriffith$elm_style_animation$Animation_Model$CurveTo(
						{
							control1: {
								ctor: '_Tuple2',
								_0: A2(
									setMotionTarget,
									_elm_lang$core$Tuple$first(_p83.control1),
									_elm_lang$core$Tuple$first(_p82.control1)),
								_1: A2(
									setMotionTarget,
									_elm_lang$core$Tuple$second(_p83.control1),
									_elm_lang$core$Tuple$second(_p82.control1))
							},
							control2: {
								ctor: '_Tuple2',
								_0: A2(
									setMotionTarget,
									_elm_lang$core$Tuple$first(_p83.control2),
									_elm_lang$core$Tuple$first(_p82.control2)),
								_1: A2(
									setMotionTarget,
									_elm_lang$core$Tuple$second(_p83.control2),
									_elm_lang$core$Tuple$second(_p82.control2))
							},
							point: {
								ctor: '_Tuple2',
								_0: A2(
									setMotionTarget,
									_elm_lang$core$Tuple$first(_p83.point),
									_elm_lang$core$Tuple$first(_p82.point)),
								_1: A2(
									setMotionTarget,
									_elm_lang$core$Tuple$second(_p83.point),
									_elm_lang$core$Tuple$second(_p82.point))
							}
						});
				} else {
					return cmd;
				}
			case 'Quadratic':
				var _p86 = _p69._0;
				var _p84 = targetCmd;
				if (_p84.ctor === 'Quadratic') {
					var _p85 = _p84._0;
					return _mdgriffith$elm_style_animation$Animation_Model$Quadratic(
						{
							control: {
								ctor: '_Tuple2',
								_0: A2(
									setMotionTarget,
									_elm_lang$core$Tuple$first(_p86.control),
									_elm_lang$core$Tuple$first(_p85.control)),
								_1: A2(
									setMotionTarget,
									_elm_lang$core$Tuple$second(_p86.control),
									_elm_lang$core$Tuple$second(_p85.control))
							},
							point: {
								ctor: '_Tuple2',
								_0: A2(
									setMotionTarget,
									_elm_lang$core$Tuple$first(_p86.point),
									_elm_lang$core$Tuple$first(_p85.point)),
								_1: A2(
									setMotionTarget,
									_elm_lang$core$Tuple$second(_p86.point),
									_elm_lang$core$Tuple$second(_p85.point))
							}
						});
				} else {
					return cmd;
				}
			case 'QuadraticTo':
				var _p89 = _p69._0;
				var _p87 = targetCmd;
				if (_p87.ctor === 'QuadraticTo') {
					var _p88 = _p87._0;
					return _mdgriffith$elm_style_animation$Animation_Model$QuadraticTo(
						{
							control: {
								ctor: '_Tuple2',
								_0: A2(
									setMotionTarget,
									_elm_lang$core$Tuple$first(_p89.control),
									_elm_lang$core$Tuple$first(_p88.control)),
								_1: A2(
									setMotionTarget,
									_elm_lang$core$Tuple$second(_p89.control),
									_elm_lang$core$Tuple$second(_p88.control))
							},
							point: {
								ctor: '_Tuple2',
								_0: A2(
									setMotionTarget,
									_elm_lang$core$Tuple$first(_p89.point),
									_elm_lang$core$Tuple$first(_p88.point)),
								_1: A2(
									setMotionTarget,
									_elm_lang$core$Tuple$second(_p89.point),
									_elm_lang$core$Tuple$second(_p88.point))
							}
						});
				} else {
					return cmd;
				}
			case 'SmoothQuadratic':
				var _p90 = targetCmd;
				if (_p90.ctor === 'SmoothQuadratic') {
					return _mdgriffith$elm_style_animation$Animation_Model$SmoothQuadratic(
						A3(
							_elm_lang$core$List$map2,
							F2(
								function (_p92, _p91) {
									var _p93 = _p92;
									var _p94 = _p91;
									return {
										ctor: '_Tuple2',
										_0: A2(setMotionTarget, _p93._0, _p94._0),
										_1: A2(setMotionTarget, _p93._1, _p94._1)
									};
								}),
							_p69._0,
							_p90._0));
				} else {
					return cmd;
				}
			case 'SmoothQuadraticTo':
				var _p95 = targetCmd;
				if (_p95.ctor === 'SmoothQuadraticTo') {
					return _mdgriffith$elm_style_animation$Animation_Model$SmoothQuadraticTo(
						A3(
							_elm_lang$core$List$map2,
							F2(
								function (_p97, _p96) {
									var _p98 = _p97;
									var _p99 = _p96;
									return {
										ctor: '_Tuple2',
										_0: A2(setMotionTarget, _p98._0, _p99._0),
										_1: A2(setMotionTarget, _p98._1, _p99._1)
									};
								}),
							_p69._0,
							_p95._0));
				} else {
					return cmd;
				}
			case 'Smooth':
				var _p100 = targetCmd;
				if (_p100.ctor === 'Smooth') {
					return _mdgriffith$elm_style_animation$Animation_Model$Smooth(
						A3(
							_elm_lang$core$List$map2,
							F2(
								function (_p102, _p101) {
									var _p103 = _p102;
									var _p104 = _p101;
									return {
										ctor: '_Tuple2',
										_0: A2(setMotionTarget, _p103._0, _p104._0),
										_1: A2(setMotionTarget, _p103._1, _p104._1)
									};
								}),
							_p69._0,
							_p100._0));
				} else {
					return cmd;
				}
			case 'SmoothTo':
				var _p105 = targetCmd;
				if (_p105.ctor === 'SmoothTo') {
					return _mdgriffith$elm_style_animation$Animation_Model$SmoothTo(
						A3(
							_elm_lang$core$List$map2,
							F2(
								function (_p107, _p106) {
									var _p108 = _p107;
									var _p109 = _p106;
									return {
										ctor: '_Tuple2',
										_0: A2(setMotionTarget, _p108._0, _p109._0),
										_1: A2(setMotionTarget, _p108._1, _p109._1)
									};
								}),
							_p69._0,
							_p105._0));
				} else {
					return cmd;
				}
			case 'ClockwiseArc':
				var _p112 = _p69._0;
				var _p110 = targetCmd;
				if (_p110.ctor === 'ClockwiseArc') {
					var _p111 = _p110._0;
					return _mdgriffith$elm_style_animation$Animation_Model$ClockwiseArc(
						function () {
							var endAngle = _p112.endAngle;
							var startAngle = _p112.startAngle;
							var radius = _p112.radius;
							var y = _p112.y;
							var x = _p112.x;
							return _elm_lang$core$Native_Utils.update(
								_p112,
								{
									x: A2(setMotionTarget, x, _p111.x),
									y: A2(setMotionTarget, y, _p111.y),
									radius: A2(setMotionTarget, radius, _p111.radius),
									startAngle: A2(setMotionTarget, startAngle, _p111.startAngle),
									endAngle: A2(setMotionTarget, endAngle, _p111.endAngle)
								});
						}());
				} else {
					return cmd;
				}
			case 'AntiClockwiseArc':
				var _p115 = _p69._0;
				var _p113 = targetCmd;
				if (_p113.ctor === 'AntiClockwiseArc') {
					var _p114 = _p113._0;
					return _mdgriffith$elm_style_animation$Animation_Model$AntiClockwiseArc(
						function () {
							var endAngle = _p115.endAngle;
							var startAngle = _p115.startAngle;
							var radius = _p115.radius;
							var y = _p115.y;
							var x = _p115.x;
							return _elm_lang$core$Native_Utils.update(
								_p115,
								{
									x: A2(setMotionTarget, x, _p114.x),
									y: A2(setMotionTarget, y, _p114.y),
									radius: A2(setMotionTarget, radius, _p114.radius),
									startAngle: A2(setMotionTarget, startAngle, _p114.startAngle),
									endAngle: A2(setMotionTarget, endAngle, _p114.endAngle)
								});
						}());
				} else {
					return cmd;
				}
			default:
				return _mdgriffith$elm_style_animation$Animation_Model$Close;
		}
	});
var _mdgriffith$elm_style_animation$Animation_Model$setTarget = F3(
	function (overrideInterpolation, current, newTarget) {
		var setMotionTarget = F2(
			function (motion, targetMotion) {
				var newMotion = overrideInterpolation ? _elm_lang$core$Native_Utils.update(
					motion,
					{
						interpolationOverride: _elm_lang$core$Maybe$Just(targetMotion.interpolation)
					}) : motion;
				var _p116 = newMotion.interpolationOverride;
				if (_p116.ctor === 'Nothing') {
					var _p117 = newMotion.interpolation;
					if (_p117.ctor === 'Easing') {
						return _elm_lang$core$Native_Utils.update(
							newMotion,
							{
								target: targetMotion.position,
								interpolation: _mdgriffith$elm_style_animation$Animation_Model$Easing(
									_elm_lang$core$Native_Utils.update(
										_p117._0,
										{start: motion.position, progress: 0}))
							});
					} else {
						return _elm_lang$core$Native_Utils.update(
							newMotion,
							{target: targetMotion.position});
					}
				} else {
					var _p118 = _p116._0;
					if (_p118.ctor === 'Easing') {
						return _elm_lang$core$Native_Utils.update(
							newMotion,
							{
								target: targetMotion.position,
								interpolationOverride: _elm_lang$core$Maybe$Just(
									_mdgriffith$elm_style_animation$Animation_Model$Easing(
										_elm_lang$core$Native_Utils.update(
											_p118._0,
											{start: motion.position, progress: 0})))
							});
					} else {
						return _elm_lang$core$Native_Utils.update(
							newMotion,
							{target: targetMotion.position});
					}
				}
			});
		var _p119 = current;
		switch (_p119.ctor) {
			case 'ExactProperty':
				return A2(_mdgriffith$elm_style_animation$Animation_Model$ExactProperty, _p119._0, _p119._1);
			case 'ColorProperty':
				var _p120 = newTarget;
				if (_p120.ctor === 'ColorProperty') {
					return A5(
						_mdgriffith$elm_style_animation$Animation_Model$ColorProperty,
						_p119._0,
						A2(setMotionTarget, _p119._1, _p120._1),
						A2(setMotionTarget, _p119._2, _p120._2),
						A2(setMotionTarget, _p119._3, _p120._3),
						A2(setMotionTarget, _p119._4, _p120._4));
				} else {
					return current;
				}
			case 'ShadowProperty':
				var _p123 = _p119._2;
				var _p121 = newTarget;
				if (_p121.ctor === 'ShadowProperty') {
					var _p122 = _p121._2;
					return A3(
						_mdgriffith$elm_style_animation$Animation_Model$ShadowProperty,
						_p119._0,
						_p119._1,
						{
							offsetX: A2(setMotionTarget, _p123.offsetX, _p122.offsetX),
							offsetY: A2(setMotionTarget, _p123.offsetY, _p122.offsetY),
							size: A2(setMotionTarget, _p123.size, _p122.size),
							blur: A2(setMotionTarget, _p123.blur, _p122.blur),
							red: A2(setMotionTarget, _p123.red, _p122.red),
							green: A2(setMotionTarget, _p123.green, _p122.green),
							blue: A2(setMotionTarget, _p123.blue, _p122.blue),
							alpha: A2(setMotionTarget, _p123.alpha, _p122.alpha)
						});
				} else {
					return current;
				}
			case 'Property':
				var _p124 = newTarget;
				if (_p124.ctor === 'Property') {
					return A2(
						_mdgriffith$elm_style_animation$Animation_Model$Property,
						_p119._0,
						A2(setMotionTarget, _p119._1, _p124._1));
				} else {
					return current;
				}
			case 'Property2':
				var _p125 = newTarget;
				if (_p125.ctor === 'Property2') {
					return A3(
						_mdgriffith$elm_style_animation$Animation_Model$Property2,
						_p119._0,
						A2(setMotionTarget, _p119._1, _p125._1),
						A2(setMotionTarget, _p119._2, _p125._2));
				} else {
					return current;
				}
			case 'Property3':
				var _p126 = newTarget;
				if (_p126.ctor === 'Property3') {
					return A4(
						_mdgriffith$elm_style_animation$Animation_Model$Property3,
						_p119._0,
						A2(setMotionTarget, _p119._1, _p126._1),
						A2(setMotionTarget, _p119._2, _p126._2),
						A2(setMotionTarget, _p119._3, _p126._3));
				} else {
					return current;
				}
			case 'Property4':
				var _p127 = newTarget;
				if (_p127.ctor === 'Property4') {
					return A5(
						_mdgriffith$elm_style_animation$Animation_Model$Property4,
						_p119._0,
						A2(setMotionTarget, _p119._1, _p127._1),
						A2(setMotionTarget, _p119._2, _p127._2),
						A2(setMotionTarget, _p119._3, _p127._3),
						A2(setMotionTarget, _p119._4, _p127._4));
				} else {
					return current;
				}
			case 'AngleProperty':
				var _p128 = newTarget;
				if (_p128.ctor === 'AngleProperty') {
					return A2(
						_mdgriffith$elm_style_animation$Animation_Model$AngleProperty,
						_p119._0,
						A2(setMotionTarget, _p119._1, _p128._1));
				} else {
					return current;
				}
			case 'Points':
				var _p129 = newTarget;
				if (_p129.ctor === 'Points') {
					var _p130 = A2(_mdgriffith$elm_style_animation$Animation_Model$matchPoints, _p119._0, _p129._0);
					var m1s = _p130._0;
					var m2s = _p130._1;
					return _mdgriffith$elm_style_animation$Animation_Model$Points(
						A3(
							_elm_lang$core$List$map2,
							F2(
								function (_p132, _p131) {
									var _p133 = _p132;
									var _p134 = _p131;
									return {
										ctor: '_Tuple2',
										_0: A2(setMotionTarget, _p133._0, _p134._0),
										_1: A2(setMotionTarget, _p133._1, _p134._1)
									};
								}),
							m1s,
							m2s));
				} else {
					return current;
				}
			default:
				var _p135 = newTarget;
				if (_p135.ctor === 'Path') {
					return _mdgriffith$elm_style_animation$Animation_Model$Path(
						A3(_elm_lang$core$List$map2, _mdgriffith$elm_style_animation$Animation_Model$setPathTarget, _p119._0, _p135._0));
				} else {
					return current;
				}
		}
	});
var _mdgriffith$elm_style_animation$Animation_Model$startTowards = F3(
	function (overrideInterpolation, current, target) {
		return A2(
			_elm_lang$core$List$filterMap,
			function (propPair) {
				var _p136 = propPair;
				if (_p136._1.ctor === 'Just') {
					return _elm_lang$core$Maybe$Just(
						A3(_mdgriffith$elm_style_animation$Animation_Model$setTarget, overrideInterpolation, _p136._0, _p136._1._0));
				} else {
					return _elm_lang$core$Maybe$Just(_p136._0);
				}
			},
			A2(_mdgriffith$elm_style_animation$Animation_Model$zipPropertiesGreedy, current, target));
	});
var _mdgriffith$elm_style_animation$Animation_Model$stepPath = F2(
	function (dt, cmd) {
		var stepCoords = function (coords) {
			return A2(
				_elm_lang$core$List$map,
				function (_p137) {
					var _p138 = _p137;
					return {
						ctor: '_Tuple2',
						_0: A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p138._0),
						_1: A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p138._1)
					};
				},
				coords);
		};
		var _p139 = cmd;
		switch (_p139.ctor) {
			case 'Move':
				return A2(
					_mdgriffith$elm_style_animation$Animation_Model$Move,
					A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p139._0),
					A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p139._1));
			case 'MoveTo':
				return A2(
					_mdgriffith$elm_style_animation$Animation_Model$MoveTo,
					A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p139._0),
					A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p139._1));
			case 'Line':
				return A2(
					_mdgriffith$elm_style_animation$Animation_Model$Line,
					A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p139._0),
					A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p139._1));
			case 'LineTo':
				return A2(
					_mdgriffith$elm_style_animation$Animation_Model$LineTo,
					A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p139._0),
					A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p139._1));
			case 'Horizontal':
				return _mdgriffith$elm_style_animation$Animation_Model$Horizontal(
					A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p139._0));
			case 'HorizontalTo':
				return _mdgriffith$elm_style_animation$Animation_Model$HorizontalTo(
					A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p139._0));
			case 'Vertical':
				return _mdgriffith$elm_style_animation$Animation_Model$Vertical(
					A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p139._0));
			case 'VerticalTo':
				return _mdgriffith$elm_style_animation$Animation_Model$VerticalTo(
					A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p139._0));
			case 'Curve':
				var _p142 = _p139._0.point;
				var _p141 = _p139._0.control2;
				var _p140 = _p139._0.control1;
				return _mdgriffith$elm_style_animation$Animation_Model$Curve(
					{
						control1: {
							ctor: '_Tuple2',
							_0: A2(
								_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation,
								dt,
								_elm_lang$core$Tuple$first(_p140)),
							_1: A2(
								_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation,
								dt,
								_elm_lang$core$Tuple$second(_p140))
						},
						control2: {
							ctor: '_Tuple2',
							_0: A2(
								_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation,
								dt,
								_elm_lang$core$Tuple$first(_p141)),
							_1: A2(
								_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation,
								dt,
								_elm_lang$core$Tuple$second(_p141))
						},
						point: {
							ctor: '_Tuple2',
							_0: A2(
								_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation,
								dt,
								_elm_lang$core$Tuple$first(_p142)),
							_1: A2(
								_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation,
								dt,
								_elm_lang$core$Tuple$second(_p142))
						}
					});
			case 'CurveTo':
				var _p145 = _p139._0.point;
				var _p144 = _p139._0.control2;
				var _p143 = _p139._0.control1;
				return _mdgriffith$elm_style_animation$Animation_Model$CurveTo(
					{
						control1: {
							ctor: '_Tuple2',
							_0: A2(
								_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation,
								dt,
								_elm_lang$core$Tuple$first(_p143)),
							_1: A2(
								_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation,
								dt,
								_elm_lang$core$Tuple$second(_p143))
						},
						control2: {
							ctor: '_Tuple2',
							_0: A2(
								_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation,
								dt,
								_elm_lang$core$Tuple$first(_p144)),
							_1: A2(
								_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation,
								dt,
								_elm_lang$core$Tuple$second(_p144))
						},
						point: {
							ctor: '_Tuple2',
							_0: A2(
								_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation,
								dt,
								_elm_lang$core$Tuple$first(_p145)),
							_1: A2(
								_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation,
								dt,
								_elm_lang$core$Tuple$second(_p145))
						}
					});
			case 'Quadratic':
				var _p147 = _p139._0.point;
				var _p146 = _p139._0.control;
				return _mdgriffith$elm_style_animation$Animation_Model$Quadratic(
					{
						control: {
							ctor: '_Tuple2',
							_0: A2(
								_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation,
								dt,
								_elm_lang$core$Tuple$first(_p146)),
							_1: A2(
								_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation,
								dt,
								_elm_lang$core$Tuple$second(_p146))
						},
						point: {
							ctor: '_Tuple2',
							_0: A2(
								_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation,
								dt,
								_elm_lang$core$Tuple$first(_p147)),
							_1: A2(
								_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation,
								dt,
								_elm_lang$core$Tuple$second(_p147))
						}
					});
			case 'QuadraticTo':
				var _p149 = _p139._0.point;
				var _p148 = _p139._0.control;
				return _mdgriffith$elm_style_animation$Animation_Model$QuadraticTo(
					{
						control: {
							ctor: '_Tuple2',
							_0: A2(
								_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation,
								dt,
								_elm_lang$core$Tuple$first(_p148)),
							_1: A2(
								_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation,
								dt,
								_elm_lang$core$Tuple$second(_p148))
						},
						point: {
							ctor: '_Tuple2',
							_0: A2(
								_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation,
								dt,
								_elm_lang$core$Tuple$first(_p149)),
							_1: A2(
								_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation,
								dt,
								_elm_lang$core$Tuple$second(_p149))
						}
					});
			case 'SmoothQuadratic':
				return _mdgriffith$elm_style_animation$Animation_Model$SmoothQuadratic(
					stepCoords(_p139._0));
			case 'SmoothQuadraticTo':
				return _mdgriffith$elm_style_animation$Animation_Model$SmoothQuadraticTo(
					stepCoords(_p139._0));
			case 'Smooth':
				return _mdgriffith$elm_style_animation$Animation_Model$Smooth(
					stepCoords(_p139._0));
			case 'SmoothTo':
				return _mdgriffith$elm_style_animation$Animation_Model$SmoothTo(
					stepCoords(_p139._0));
			case 'ClockwiseArc':
				var _p150 = _p139._0;
				return _mdgriffith$elm_style_animation$Animation_Model$ClockwiseArc(
					_elm_lang$core$Native_Utils.update(
						_p150,
						{
							x: A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p150.x),
							y: A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p150.y),
							radius: A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p150.radius),
							startAngle: A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p150.startAngle),
							endAngle: A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p150.endAngle)
						}));
			case 'AntiClockwiseArc':
				var _p151 = _p139._0;
				return _mdgriffith$elm_style_animation$Animation_Model$AntiClockwiseArc(
					_elm_lang$core$Native_Utils.update(
						_p151,
						{
							x: A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p151.x),
							y: A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p151.y),
							radius: A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p151.radius),
							startAngle: A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p151.startAngle),
							endAngle: A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p151.endAngle)
						}));
			default:
				return _mdgriffith$elm_style_animation$Animation_Model$Close;
		}
	});
var _mdgriffith$elm_style_animation$Animation_Model$step = F2(
	function (dt, props) {
		var stepProp = function (property) {
			var _p152 = property;
			switch (_p152.ctor) {
				case 'ExactProperty':
					return A2(_mdgriffith$elm_style_animation$Animation_Model$ExactProperty, _p152._0, _p152._1);
				case 'Property':
					return A2(
						_mdgriffith$elm_style_animation$Animation_Model$Property,
						_p152._0,
						A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p152._1));
				case 'Property2':
					return A3(
						_mdgriffith$elm_style_animation$Animation_Model$Property2,
						_p152._0,
						A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p152._1),
						A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p152._2));
				case 'Property3':
					return A4(
						_mdgriffith$elm_style_animation$Animation_Model$Property3,
						_p152._0,
						A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p152._1),
						A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p152._2),
						A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p152._3));
				case 'Property4':
					return A5(
						_mdgriffith$elm_style_animation$Animation_Model$Property4,
						_p152._0,
						A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p152._1),
						A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p152._2),
						A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p152._3),
						A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p152._4));
				case 'AngleProperty':
					return A2(
						_mdgriffith$elm_style_animation$Animation_Model$AngleProperty,
						_p152._0,
						A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p152._1));
				case 'ColorProperty':
					return A5(
						_mdgriffith$elm_style_animation$Animation_Model$ColorProperty,
						_p152._0,
						A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p152._1),
						A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p152._2),
						A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p152._3),
						A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p152._4));
				case 'ShadowProperty':
					var _p153 = _p152._2;
					return A3(
						_mdgriffith$elm_style_animation$Animation_Model$ShadowProperty,
						_p152._0,
						_p152._1,
						{
							offsetX: A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p153.offsetX),
							offsetY: A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p153.offsetY),
							size: A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p153.size),
							blur: A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p153.blur),
							red: A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p153.red),
							green: A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p153.green),
							blue: A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p153.blue),
							alpha: A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p153.alpha)
						});
				case 'Points':
					return _mdgriffith$elm_style_animation$Animation_Model$Points(
						A2(
							_elm_lang$core$List$map,
							function (_p154) {
								var _p155 = _p154;
								return {
									ctor: '_Tuple2',
									_0: A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p155._0),
									_1: A2(_mdgriffith$elm_style_animation$Animation_Model$stepInterpolation, dt, _p155._1)
								};
							},
							_p152._0));
				default:
					return _mdgriffith$elm_style_animation$Animation_Model$Path(
						A2(
							_elm_lang$core$List$map,
							_mdgriffith$elm_style_animation$Animation_Model$stepPath(dt),
							_p152._0));
			}
		};
		return A2(_elm_lang$core$List$map, stepProp, props);
	});
var _mdgriffith$elm_style_animation$Animation_Model$resolveSteps = F3(
	function (currentStyle, steps, dt) {
		resolveSteps:
		while (true) {
			var _p156 = _elm_lang$core$List$head(steps);
			if (_p156.ctor === 'Nothing') {
				return {
					ctor: '_Tuple3',
					_0: currentStyle,
					_1: {ctor: '[]'},
					_2: {ctor: '[]'}
				};
			} else {
				var _p157 = _p156._0;
				switch (_p157.ctor) {
					case 'Wait':
						var _p158 = _p157._0;
						if (_elm_lang$core$Native_Utils.cmp(_p158, 0) < 1) {
							var _v70 = currentStyle,
								_v71 = A2(_elm_lang$core$List$drop, 1, steps),
								_v72 = dt;
							currentStyle = _v70;
							steps = _v71;
							dt = _v72;
							continue resolveSteps;
						} else {
							return {
								ctor: '_Tuple3',
								_0: currentStyle,
								_1: {ctor: '[]'},
								_2: {
									ctor: '::',
									_0: _mdgriffith$elm_style_animation$Animation_Model$Wait(_p158 - dt),
									_1: A2(_elm_lang$core$List$drop, 1, steps)
								}
							};
						}
					case 'Send':
						var _p159 = A3(
							_mdgriffith$elm_style_animation$Animation_Model$resolveSteps,
							currentStyle,
							A2(_elm_lang$core$List$drop, 1, steps),
							dt);
						var newStyle = _p159._0;
						var msgs = _p159._1;
						var remainingSteps = _p159._2;
						return {
							ctor: '_Tuple3',
							_0: newStyle,
							_1: {ctor: '::', _0: _p157._0, _1: msgs},
							_2: remainingSteps
						};
					case 'To':
						var _v73 = A3(_mdgriffith$elm_style_animation$Animation_Model$startTowards, false, currentStyle, _p157._0),
							_v74 = {
							ctor: '::',
							_0: _mdgriffith$elm_style_animation$Animation_Model$Step,
							_1: A2(_elm_lang$core$List$drop, 1, steps)
						},
							_v75 = dt;
						currentStyle = _v73;
						steps = _v74;
						dt = _v75;
						continue resolveSteps;
					case 'ToWith':
						var _v76 = A3(_mdgriffith$elm_style_animation$Animation_Model$startTowards, true, currentStyle, _p157._0),
							_v77 = {
							ctor: '::',
							_0: _mdgriffith$elm_style_animation$Animation_Model$Step,
							_1: A2(_elm_lang$core$List$drop, 1, steps)
						},
							_v78 = dt;
						currentStyle = _v76;
						steps = _v77;
						dt = _v78;
						continue resolveSteps;
					case 'Set':
						var _v79 = A2(_mdgriffith$elm_style_animation$Animation_Model$replaceProps, currentStyle, _p157._0),
							_v80 = A2(_elm_lang$core$List$drop, 1, steps),
							_v81 = dt;
						currentStyle = _v79;
						steps = _v80;
						dt = _v81;
						continue resolveSteps;
					case 'Step':
						var stepped = A2(_mdgriffith$elm_style_animation$Animation_Model$step, dt, currentStyle);
						return A2(_elm_lang$core$List$all, _mdgriffith$elm_style_animation$Animation_Model$isDone, stepped) ? {
							ctor: '_Tuple3',
							_0: A2(
								_elm_lang$core$List$map,
								_mdgriffith$elm_style_animation$Animation_Model$mapToMotion(
									function (m) {
										return _elm_lang$core$Native_Utils.update(
											m,
											{interpolationOverride: _elm_lang$core$Maybe$Nothing});
									}),
								stepped),
							_1: {ctor: '[]'},
							_2: A2(_elm_lang$core$List$drop, 1, steps)
						} : {
							ctor: '_Tuple3',
							_0: stepped,
							_1: {ctor: '[]'},
							_2: steps
						};
					case 'Loop':
						var _p160 = _p157._0;
						var _v82 = currentStyle,
							_v83 = A2(
							_elm_lang$core$Basics_ops['++'],
							_p160,
							{
								ctor: '::',
								_0: _mdgriffith$elm_style_animation$Animation_Model$Loop(_p160),
								_1: {ctor: '[]'}
							}),
							_v84 = dt;
						currentStyle = _v82;
						steps = _v83;
						dt = _v84;
						continue resolveSteps;
					default:
						var _p162 = _p157._1;
						var _p161 = _p157._0;
						if (_elm_lang$core$Native_Utils.eq(_p161, 0)) {
							return {
								ctor: '_Tuple3',
								_0: currentStyle,
								_1: {ctor: '[]'},
								_2: A2(_elm_lang$core$List$drop, 1, _p162)
							};
						} else {
							var _v85 = currentStyle,
								_v86 = A2(
								_elm_lang$core$Basics_ops['++'],
								_p162,
								{
									ctor: '::',
									_0: A2(_mdgriffith$elm_style_animation$Animation_Model$Repeat, _p161 - 1, _p162),
									_1: {ctor: '[]'}
								}),
								_v87 = dt;
							currentStyle = _v85;
							steps = _v86;
							dt = _v87;
							continue resolveSteps;
						}
				}
			}
		}
	});
var _mdgriffith$elm_style_animation$Animation_Model$updateAnimation = F2(
	function (_p164, _p163) {
		var _p165 = _p164;
		var _p166 = _p163;
		var _p175 = _p166._0;
		var timing = A2(_mdgriffith$elm_style_animation$Animation_Model$refreshTiming, _p165._0, _p175.timing);
		var _p167 = A2(
			_elm_lang$core$List$partition,
			function (_p168) {
				var _p169 = _p168;
				return _elm_lang$core$Native_Utils.cmp(_p169._0, 0) < 1;
			},
			A2(
				_elm_lang$core$List$map,
				function (_p170) {
					var _p171 = _p170;
					return {ctor: '_Tuple2', _0: _p171._0 - timing.dt, _1: _p171._1};
				},
				_p175.interruption));
		var readyInterruption = _p167._0;
		var queuedInterruptions = _p167._1;
		var _p172 = function () {
			var _p173 = _elm_lang$core$List$head(readyInterruption);
			if (_p173.ctor === 'Just') {
				return {
					ctor: '_Tuple2',
					_0: _p173._0._1,
					_1: A2(
						_elm_lang$core$List$map,
						_mdgriffith$elm_style_animation$Animation_Model$mapToMotion(
							function (m) {
								return _elm_lang$core$Native_Utils.update(
									m,
									{interpolationOverride: _elm_lang$core$Maybe$Nothing});
							}),
						_p175.style)
				};
			} else {
				return {ctor: '_Tuple2', _0: _p175.steps, _1: _p175.style};
			}
		}();
		var steps = _p172._0;
		var style = _p172._1;
		var _p174 = A3(_mdgriffith$elm_style_animation$Animation_Model$resolveSteps, style, steps, timing.dt);
		var revisedStyle = _p174._0;
		var sentMessages = _p174._1;
		var revisedSteps = _p174._2;
		return {
			ctor: '_Tuple2',
			_0: _mdgriffith$elm_style_animation$Animation_Model$Animation(
				_elm_lang$core$Native_Utils.update(
					_p175,
					{
						timing: timing,
						interruption: queuedInterruptions,
						running: (!_elm_lang$core$Native_Utils.eq(
							_elm_lang$core$List$length(revisedSteps),
							0)) || (!_elm_lang$core$Native_Utils.eq(
							_elm_lang$core$List$length(queuedInterruptions),
							0)),
						steps: revisedSteps,
						style: revisedStyle
					})),
			_1: _elm_lang$core$Platform_Cmd$batch(
				A2(
					_elm_lang$core$List$map,
					function (m) {
						return A2(
							_elm_lang$core$Task$perform,
							_elm_lang$core$Basics$identity,
							_elm_lang$core$Task$succeed(m));
					},
					sentMessages))
		};
	});

var _mdgriffith$elm_style_animation$Animation$pathCmdValue = function (cmd) {
	var renderPoints = function (coords) {
		return A2(
			_elm_lang$core$String$join,
			' ',
			A2(
				_elm_lang$core$List$map,
				function (_p0) {
					var _p1 = _p0;
					return A2(
						_elm_lang$core$Basics_ops['++'],
						_elm_lang$core$Basics$toString(_p1._0.position),
						A2(
							_elm_lang$core$Basics_ops['++'],
							',',
							_elm_lang$core$Basics$toString(_p1._1.position)));
				},
				coords));
	};
	var _p2 = cmd;
	switch (_p2.ctor) {
		case 'Move':
			return A2(
				_elm_lang$core$Basics_ops['++'],
				'm ',
				A2(
					_elm_lang$core$Basics_ops['++'],
					_elm_lang$core$Basics$toString(_p2._0.position),
					A2(
						_elm_lang$core$Basics_ops['++'],
						',',
						_elm_lang$core$Basics$toString(_p2._1.position))));
		case 'MoveTo':
			return A2(
				_elm_lang$core$Basics_ops['++'],
				'M ',
				A2(
					_elm_lang$core$Basics_ops['++'],
					_elm_lang$core$Basics$toString(_p2._0.position),
					A2(
						_elm_lang$core$Basics_ops['++'],
						',',
						_elm_lang$core$Basics$toString(_p2._1.position))));
		case 'Line':
			return A2(
				_elm_lang$core$Basics_ops['++'],
				'l ',
				A2(
					_elm_lang$core$Basics_ops['++'],
					_elm_lang$core$Basics$toString(_p2._0.position),
					A2(
						_elm_lang$core$Basics_ops['++'],
						',',
						_elm_lang$core$Basics$toString(_p2._1.position))));
		case 'LineTo':
			return A2(
				_elm_lang$core$Basics_ops['++'],
				'L ',
				A2(
					_elm_lang$core$Basics_ops['++'],
					_elm_lang$core$Basics$toString(_p2._0.position),
					A2(
						_elm_lang$core$Basics_ops['++'],
						',',
						_elm_lang$core$Basics$toString(_p2._1.position))));
		case 'Horizontal':
			return A2(
				_elm_lang$core$Basics_ops['++'],
				'h ',
				_elm_lang$core$Basics$toString(_p2._0.position));
		case 'HorizontalTo':
			return A2(
				_elm_lang$core$Basics_ops['++'],
				'H ',
				_elm_lang$core$Basics$toString(_p2._0.position));
		case 'Vertical':
			return A2(
				_elm_lang$core$Basics_ops['++'],
				'v ',
				_elm_lang$core$Basics$toString(_p2._0.position));
		case 'VerticalTo':
			return A2(
				_elm_lang$core$Basics_ops['++'],
				'V ',
				_elm_lang$core$Basics$toString(_p2._0.position));
		case 'Curve':
			var _p3 = _p2._0.point;
			var p1x = _p3._0;
			var p1y = _p3._1;
			var _p4 = _p2._0.control2;
			var c2x = _p4._0;
			var c2y = _p4._1;
			var _p5 = _p2._0.control1;
			var c1x = _p5._0;
			var c1y = _p5._1;
			return A2(
				_elm_lang$core$Basics_ops['++'],
				'c ',
				A2(
					_elm_lang$core$Basics_ops['++'],
					_elm_lang$core$Basics$toString(c1x.position),
					A2(
						_elm_lang$core$Basics_ops['++'],
						' ',
						A2(
							_elm_lang$core$Basics_ops['++'],
							_elm_lang$core$Basics$toString(c1y.position),
							A2(
								_elm_lang$core$Basics_ops['++'],
								', ',
								A2(
									_elm_lang$core$Basics_ops['++'],
									_elm_lang$core$Basics$toString(c2x.position),
									A2(
										_elm_lang$core$Basics_ops['++'],
										' ',
										A2(
											_elm_lang$core$Basics_ops['++'],
											_elm_lang$core$Basics$toString(c2y.position),
											A2(
												_elm_lang$core$Basics_ops['++'],
												', ',
												A2(
													_elm_lang$core$Basics_ops['++'],
													_elm_lang$core$Basics$toString(p1x.position),
													A2(
														_elm_lang$core$Basics_ops['++'],
														' ',
														_elm_lang$core$Basics$toString(p1y.position))))))))))));
		case 'CurveTo':
			var _p6 = _p2._0.point;
			var p1x = _p6._0;
			var p1y = _p6._1;
			var _p7 = _p2._0.control2;
			var c2x = _p7._0;
			var c2y = _p7._1;
			var _p8 = _p2._0.control1;
			var c1x = _p8._0;
			var c1y = _p8._1;
			return A2(
				_elm_lang$core$Basics_ops['++'],
				'C ',
				A2(
					_elm_lang$core$Basics_ops['++'],
					_elm_lang$core$Basics$toString(c1x.position),
					A2(
						_elm_lang$core$Basics_ops['++'],
						' ',
						A2(
							_elm_lang$core$Basics_ops['++'],
							_elm_lang$core$Basics$toString(c1y.position),
							A2(
								_elm_lang$core$Basics_ops['++'],
								', ',
								A2(
									_elm_lang$core$Basics_ops['++'],
									_elm_lang$core$Basics$toString(c2x.position),
									A2(
										_elm_lang$core$Basics_ops['++'],
										' ',
										A2(
											_elm_lang$core$Basics_ops['++'],
											_elm_lang$core$Basics$toString(c2y.position),
											A2(
												_elm_lang$core$Basics_ops['++'],
												', ',
												A2(
													_elm_lang$core$Basics_ops['++'],
													_elm_lang$core$Basics$toString(p1x.position),
													A2(
														_elm_lang$core$Basics_ops['++'],
														' ',
														_elm_lang$core$Basics$toString(p1y.position))))))))))));
		case 'Quadratic':
			var _p9 = _p2._0.point;
			var p1x = _p9._0;
			var p1y = _p9._1;
			var _p10 = _p2._0.control;
			var c1x = _p10._0;
			var c1y = _p10._1;
			return A2(
				_elm_lang$core$Basics_ops['++'],
				'q ',
				A2(
					_elm_lang$core$Basics_ops['++'],
					_elm_lang$core$Basics$toString(c1x.position),
					A2(
						_elm_lang$core$Basics_ops['++'],
						' ',
						A2(
							_elm_lang$core$Basics_ops['++'],
							_elm_lang$core$Basics$toString(c1y.position),
							A2(
								_elm_lang$core$Basics_ops['++'],
								', ',
								A2(
									_elm_lang$core$Basics_ops['++'],
									_elm_lang$core$Basics$toString(p1x.position),
									A2(
										_elm_lang$core$Basics_ops['++'],
										' ',
										_elm_lang$core$Basics$toString(p1y.position))))))));
		case 'QuadraticTo':
			var _p11 = _p2._0.point;
			var p1x = _p11._0;
			var p1y = _p11._1;
			var _p12 = _p2._0.control;
			var c1x = _p12._0;
			var c1y = _p12._1;
			return A2(
				_elm_lang$core$Basics_ops['++'],
				'Q ',
				A2(
					_elm_lang$core$Basics_ops['++'],
					_elm_lang$core$Basics$toString(c1x.position),
					A2(
						_elm_lang$core$Basics_ops['++'],
						' ',
						A2(
							_elm_lang$core$Basics_ops['++'],
							_elm_lang$core$Basics$toString(c1y.position),
							A2(
								_elm_lang$core$Basics_ops['++'],
								', ',
								A2(
									_elm_lang$core$Basics_ops['++'],
									_elm_lang$core$Basics$toString(p1x.position),
									A2(
										_elm_lang$core$Basics_ops['++'],
										' ',
										_elm_lang$core$Basics$toString(p1y.position))))))));
		case 'SmoothQuadratic':
			return A2(
				_elm_lang$core$Basics_ops['++'],
				't ',
				renderPoints(_p2._0));
		case 'SmoothQuadraticTo':
			return A2(
				_elm_lang$core$Basics_ops['++'],
				'T ',
				renderPoints(_p2._0));
		case 'Smooth':
			return A2(
				_elm_lang$core$Basics_ops['++'],
				's ',
				renderPoints(_p2._0));
		case 'SmoothTo':
			return A2(
				_elm_lang$core$Basics_ops['++'],
				'S ',
				renderPoints(_p2._0));
		case 'ClockwiseArc':
			var _p13 = _p2._0;
			var deltaAngle = _p13.endAngle.position - _p13.startAngle.position;
			if (_elm_lang$core$Native_Utils.cmp(deltaAngle, 360 - 1.0e-6) > 0) {
				var dy = _p13.radius.position * _elm_lang$core$Basics$sin(
					_elm_lang$core$Basics$degrees(_p13.startAngle.position));
				var dx = _p13.radius.position * _elm_lang$core$Basics$cos(
					_elm_lang$core$Basics$degrees(_p13.startAngle.position));
				return A2(
					_elm_lang$core$Basics_ops['++'],
					'A ',
					A2(
						_elm_lang$core$Basics_ops['++'],
						_elm_lang$core$Basics$toString(_p13.radius.position),
						A2(
							_elm_lang$core$Basics_ops['++'],
							',',
							A2(
								_elm_lang$core$Basics_ops['++'],
								_elm_lang$core$Basics$toString(_p13.radius.position),
								A2(
									_elm_lang$core$Basics_ops['++'],
									',0,1,1,',
									A2(
										_elm_lang$core$Basics_ops['++'],
										_elm_lang$core$Basics$toString(_p13.x.position - dx),
										A2(
											_elm_lang$core$Basics_ops['++'],
											',',
											A2(
												_elm_lang$core$Basics_ops['++'],
												_elm_lang$core$Basics$toString(_p13.y.position - dy),
												A2(
													_elm_lang$core$Basics_ops['++'],
													' A ',
													A2(
														_elm_lang$core$Basics_ops['++'],
														_elm_lang$core$Basics$toString(_p13.radius.position),
														A2(
															_elm_lang$core$Basics_ops['++'],
															',',
															A2(
																_elm_lang$core$Basics_ops['++'],
																_elm_lang$core$Basics$toString(_p13.radius.position),
																A2(
																	_elm_lang$core$Basics_ops['++'],
																	',0,1,1,',
																	A2(
																		_elm_lang$core$Basics_ops['++'],
																		_elm_lang$core$Basics$toString(_p13.x.position + dx),
																		A2(
																			_elm_lang$core$Basics_ops['++'],
																			',',
																			_elm_lang$core$Basics$toString(_p13.y.position + dy))))))))))))))));
			} else {
				return A2(
					_elm_lang$core$Basics_ops['++'],
					'A ',
					A2(
						_elm_lang$core$Basics_ops['++'],
						_elm_lang$core$Basics$toString(_p13.radius.position),
						A2(
							_elm_lang$core$Basics_ops['++'],
							',',
							A2(
								_elm_lang$core$Basics_ops['++'],
								_elm_lang$core$Basics$toString(_p13.radius.position),
								A2(
									_elm_lang$core$Basics_ops['++'],
									' 0 ',
									A2(
										_elm_lang$core$Basics_ops['++'],
										(_elm_lang$core$Native_Utils.cmp(deltaAngle, 180) > -1) ? '1' : '0',
										A2(
											_elm_lang$core$Basics_ops['++'],
											' ',
											A2(
												_elm_lang$core$Basics_ops['++'],
												'1',
												A2(
													_elm_lang$core$Basics_ops['++'],
													' ',
													A2(
														_elm_lang$core$Basics_ops['++'],
														_elm_lang$core$Basics$toString(
															_p13.x.position + (_p13.radius.position * _elm_lang$core$Basics$cos(
																_elm_lang$core$Basics$degrees(_p13.endAngle.position)))),
														A2(
															_elm_lang$core$Basics_ops['++'],
															',',
															_elm_lang$core$Basics$toString(
																_p13.y.position + (_p13.radius.position * _elm_lang$core$Basics$sin(
																	_elm_lang$core$Basics$degrees(_p13.endAngle.position)))))))))))))));
			}
		case 'AntiClockwiseArc':
			var _p14 = _p2._0;
			var deltaAngle = _p14.endAngle.position - _p14.startAngle.position;
			if (_elm_lang$core$Native_Utils.cmp(deltaAngle, 360 - 1.0e-6) > 0) {
				var dy = _p14.radius.position * _elm_lang$core$Basics$sin(
					_elm_lang$core$Basics$degrees(_p14.startAngle.position));
				var dx = _p14.radius.position * _elm_lang$core$Basics$cos(
					_elm_lang$core$Basics$degrees(_p14.startAngle.position));
				return A2(
					_elm_lang$core$Basics_ops['++'],
					'A ',
					A2(
						_elm_lang$core$Basics_ops['++'],
						_elm_lang$core$Basics$toString(_p14.radius.position),
						A2(
							_elm_lang$core$Basics_ops['++'],
							',',
							A2(
								_elm_lang$core$Basics_ops['++'],
								_elm_lang$core$Basics$toString(_p14.radius.position),
								A2(
									_elm_lang$core$Basics_ops['++'],
									',0,1,0,',
									A2(
										_elm_lang$core$Basics_ops['++'],
										_elm_lang$core$Basics$toString(_p14.x.position - dx),
										A2(
											_elm_lang$core$Basics_ops['++'],
											',',
											A2(
												_elm_lang$core$Basics_ops['++'],
												_elm_lang$core$Basics$toString(_p14.y.position - dy),
												A2(
													_elm_lang$core$Basics_ops['++'],
													' A ',
													A2(
														_elm_lang$core$Basics_ops['++'],
														_elm_lang$core$Basics$toString(_p14.radius.position),
														A2(
															_elm_lang$core$Basics_ops['++'],
															',',
															A2(
																_elm_lang$core$Basics_ops['++'],
																_elm_lang$core$Basics$toString(_p14.radius.position),
																A2(
																	_elm_lang$core$Basics_ops['++'],
																	',0,1,1,',
																	A2(
																		_elm_lang$core$Basics_ops['++'],
																		_elm_lang$core$Basics$toString(_p14.x.position + dx),
																		A2(
																			_elm_lang$core$Basics_ops['++'],
																			',',
																			_elm_lang$core$Basics$toString(_p14.y.position + dy))))))))))))))));
			} else {
				return A2(
					_elm_lang$core$Basics_ops['++'],
					'A ',
					A2(
						_elm_lang$core$Basics_ops['++'],
						_elm_lang$core$Basics$toString(_p14.radius.position),
						A2(
							_elm_lang$core$Basics_ops['++'],
							',',
							A2(
								_elm_lang$core$Basics_ops['++'],
								_elm_lang$core$Basics$toString(_p14.radius.position),
								A2(
									_elm_lang$core$Basics_ops['++'],
									' 0 ',
									A2(
										_elm_lang$core$Basics_ops['++'],
										(_elm_lang$core$Native_Utils.cmp(_p14.startAngle.position - _p14.endAngle.position, 180) > -1) ? '1' : '0',
										A2(
											_elm_lang$core$Basics_ops['++'],
											' ',
											A2(
												_elm_lang$core$Basics_ops['++'],
												'0',
												A2(
													_elm_lang$core$Basics_ops['++'],
													' ',
													A2(
														_elm_lang$core$Basics_ops['++'],
														_elm_lang$core$Basics$toString(
															_p14.x.position + (_p14.radius.position * _elm_lang$core$Basics$cos(_p14.endAngle.position))),
														A2(
															_elm_lang$core$Basics_ops['++'],
															',',
															_elm_lang$core$Basics$toString(
																_p14.y.position + (_p14.radius.position * _elm_lang$core$Basics$sin(_p14.endAngle.position))))))))))))));
			}
		default:
			return 'z';
	}
};
var _mdgriffith$elm_style_animation$Animation$propertyValue = F2(
	function (prop, delim) {
		var _p15 = prop;
		switch (_p15.ctor) {
			case 'ExactProperty':
				return _p15._1;
			case 'ColorProperty':
				return A2(
					_elm_lang$core$Basics_ops['++'],
					'rgba(',
					A2(
						_elm_lang$core$Basics_ops['++'],
						_elm_lang$core$Basics$toString(
							_elm_lang$core$Basics$round(_p15._1.position)),
						A2(
							_elm_lang$core$Basics_ops['++'],
							',',
							A2(
								_elm_lang$core$Basics_ops['++'],
								_elm_lang$core$Basics$toString(
									_elm_lang$core$Basics$round(_p15._2.position)),
								A2(
									_elm_lang$core$Basics_ops['++'],
									',',
									A2(
										_elm_lang$core$Basics_ops['++'],
										_elm_lang$core$Basics$toString(
											_elm_lang$core$Basics$round(_p15._3.position)),
										A2(
											_elm_lang$core$Basics_ops['++'],
											',',
											A2(
												_elm_lang$core$Basics_ops['++'],
												_elm_lang$core$Basics$toString(_p15._4.position),
												')'))))))));
			case 'ShadowProperty':
				var _p17 = _p15._2;
				var _p16 = _p15._0;
				return A2(
					_elm_lang$core$Basics_ops['++'],
					_p15._1 ? 'inset ' : '',
					A2(
						_elm_lang$core$Basics_ops['++'],
						_elm_lang$core$Basics$toString(_p17.offsetX.position),
						A2(
							_elm_lang$core$Basics_ops['++'],
							'px',
							A2(
								_elm_lang$core$Basics_ops['++'],
								' ',
								A2(
									_elm_lang$core$Basics_ops['++'],
									_elm_lang$core$Basics$toString(_p17.offsetY.position),
									A2(
										_elm_lang$core$Basics_ops['++'],
										'px',
										A2(
											_elm_lang$core$Basics_ops['++'],
											' ',
											A2(
												_elm_lang$core$Basics_ops['++'],
												_elm_lang$core$Basics$toString(_p17.blur.position),
												A2(
													_elm_lang$core$Basics_ops['++'],
													'px',
													A2(
														_elm_lang$core$Basics_ops['++'],
														' ',
														A2(
															_elm_lang$core$Basics_ops['++'],
															(_elm_lang$core$Native_Utils.eq(_p16, 'text-shadow') || _elm_lang$core$Native_Utils.eq(_p16, 'drop-shadow')) ? '' : A2(
																_elm_lang$core$Basics_ops['++'],
																_elm_lang$core$Basics$toString(_p17.size.position),
																A2(_elm_lang$core$Basics_ops['++'], 'px', ' ')),
															A2(
																_elm_lang$core$Basics_ops['++'],
																'rgba(',
																A2(
																	_elm_lang$core$Basics_ops['++'],
																	_elm_lang$core$Basics$toString(
																		_elm_lang$core$Basics$round(_p17.red.position)),
																	A2(
																		_elm_lang$core$Basics_ops['++'],
																		', ',
																		A2(
																			_elm_lang$core$Basics_ops['++'],
																			_elm_lang$core$Basics$toString(
																				_elm_lang$core$Basics$round(_p17.green.position)),
																			A2(
																				_elm_lang$core$Basics_ops['++'],
																				', ',
																				A2(
																					_elm_lang$core$Basics_ops['++'],
																					_elm_lang$core$Basics$toString(
																						_elm_lang$core$Basics$round(_p17.blue.position)),
																					A2(
																						_elm_lang$core$Basics_ops['++'],
																						', ',
																						A2(
																							_elm_lang$core$Basics_ops['++'],
																							_elm_lang$core$Basics$toString(_p17.alpha.position),
																							')')))))))))))))))))));
			case 'Property':
				var _p18 = _p15._1;
				return A2(
					_elm_lang$core$Basics_ops['++'],
					_elm_lang$core$Basics$toString(_p18.position),
					_p18.unit);
			case 'Property2':
				var _p20 = _p15._2;
				var _p19 = _p15._1;
				return A2(
					_elm_lang$core$Basics_ops['++'],
					_elm_lang$core$Basics$toString(_p19.position),
					A2(
						_elm_lang$core$Basics_ops['++'],
						_p19.unit,
						A2(
							_elm_lang$core$Basics_ops['++'],
							delim,
							A2(
								_elm_lang$core$Basics_ops['++'],
								_elm_lang$core$Basics$toString(_p20.position),
								_p20.unit))));
			case 'Property3':
				var _p23 = _p15._3;
				var _p22 = _p15._2;
				var _p21 = _p15._1;
				return A2(
					_elm_lang$core$Basics_ops['++'],
					_elm_lang$core$Basics$toString(_p21.position),
					A2(
						_elm_lang$core$Basics_ops['++'],
						_p21.unit,
						A2(
							_elm_lang$core$Basics_ops['++'],
							delim,
							A2(
								_elm_lang$core$Basics_ops['++'],
								_elm_lang$core$Basics$toString(_p22.position),
								A2(
									_elm_lang$core$Basics_ops['++'],
									_p22.unit,
									A2(
										_elm_lang$core$Basics_ops['++'],
										delim,
										A2(
											_elm_lang$core$Basics_ops['++'],
											_elm_lang$core$Basics$toString(_p23.position),
											_p23.unit)))))));
			case 'Property4':
				var _p27 = _p15._4;
				var _p26 = _p15._3;
				var _p25 = _p15._2;
				var _p24 = _p15._1;
				return A2(
					_elm_lang$core$Basics_ops['++'],
					_elm_lang$core$Basics$toString(_p24.position),
					A2(
						_elm_lang$core$Basics_ops['++'],
						_p24.unit,
						A2(
							_elm_lang$core$Basics_ops['++'],
							delim,
							A2(
								_elm_lang$core$Basics_ops['++'],
								_elm_lang$core$Basics$toString(_p25.position),
								A2(
									_elm_lang$core$Basics_ops['++'],
									_p25.unit,
									A2(
										_elm_lang$core$Basics_ops['++'],
										delim,
										A2(
											_elm_lang$core$Basics_ops['++'],
											_elm_lang$core$Basics$toString(_p26.position),
											A2(
												_elm_lang$core$Basics_ops['++'],
												_p26.unit,
												A2(
													_elm_lang$core$Basics_ops['++'],
													delim,
													A2(
														_elm_lang$core$Basics_ops['++'],
														_elm_lang$core$Basics$toString(_p27.position),
														_p27.unit))))))))));
			case 'AngleProperty':
				var _p28 = _p15._1;
				return A2(
					_elm_lang$core$Basics_ops['++'],
					_elm_lang$core$Basics$toString(_p28.position),
					_p28.unit);
			case 'Points':
				return A2(
					_elm_lang$core$String$join,
					' ',
					A2(
						_elm_lang$core$List$map,
						function (_p29) {
							var _p30 = _p29;
							return A2(
								_elm_lang$core$Basics_ops['++'],
								_elm_lang$core$Basics$toString(_p30._0.position),
								A2(
									_elm_lang$core$Basics_ops['++'],
									',',
									_elm_lang$core$Basics$toString(_p30._1.position)));
						},
						_p15._0));
			default:
				return A2(
					_elm_lang$core$String$join,
					' ',
					A2(_elm_lang$core$List$map, _mdgriffith$elm_style_animation$Animation$pathCmdValue, _p15._0));
		}
	});
var _mdgriffith$elm_style_animation$Animation$displayModeName = function (mode) {
	var _p31 = mode;
	switch (_p31.ctor) {
		case 'None':
			return 'none';
		case 'Inline':
			return 'inline';
		case 'InlineBlock':
			return 'inline-block';
		case 'Block':
			return 'block';
		case 'Flex':
			return 'flex';
		case 'InlineFlex':
			return 'inline-flex';
		default:
			return 'list-item';
	}
};
var _mdgriffith$elm_style_animation$Animation$isAttr = function (prop) {
	return A2(
		_elm_lang$core$String$startsWith,
		'attr:',
		_mdgriffith$elm_style_animation$Animation_Model$propertyName(prop)) || function () {
		var _p32 = prop;
		switch (_p32.ctor) {
			case 'Points':
				return true;
			case 'Path':
				return true;
			case 'Property':
				var _p33 = _p32._0;
				return _elm_lang$core$Native_Utils.eq(_p33, 'cx') || (_elm_lang$core$Native_Utils.eq(_p33, 'cy') || (_elm_lang$core$Native_Utils.eq(_p33, 'x') || (_elm_lang$core$Native_Utils.eq(_p33, 'y') || (_elm_lang$core$Native_Utils.eq(_p33, 'rx') || (_elm_lang$core$Native_Utils.eq(_p33, 'ry') || (_elm_lang$core$Native_Utils.eq(_p33, 'r') || _elm_lang$core$Native_Utils.eq(_p33, 'offset')))))));
			case 'Property4':
				return _elm_lang$core$Native_Utils.eq(_p32._0, 'viewBox');
			default:
				return false;
		}
	}();
};
var _mdgriffith$elm_style_animation$Animation$webkitPrefix = '-webkit-';
var _mdgriffith$elm_style_animation$Animation$iePrefix = '-ms-';
var _mdgriffith$elm_style_animation$Animation$prefix = function (stylePair) {
	var propValue = _elm_lang$core$Tuple$second(stylePair);
	var propName = _elm_lang$core$Tuple$first(stylePair);
	var _p34 = propName;
	switch (_p34) {
		case 'transform':
			return {
				ctor: '::',
				_0: stylePair,
				_1: {
					ctor: '::',
					_0: {
						ctor: '_Tuple2',
						_0: A2(_elm_lang$core$Basics_ops['++'], _mdgriffith$elm_style_animation$Animation$iePrefix, propName),
						_1: propValue
					},
					_1: {
						ctor: '::',
						_0: {
							ctor: '_Tuple2',
							_0: A2(_elm_lang$core$Basics_ops['++'], _mdgriffith$elm_style_animation$Animation$webkitPrefix, propName),
							_1: propValue
						},
						_1: {ctor: '[]'}
					}
				}
			};
		case 'transform-origin':
			return {
				ctor: '::',
				_0: stylePair,
				_1: {
					ctor: '::',
					_0: {
						ctor: '_Tuple2',
						_0: A2(_elm_lang$core$Basics_ops['++'], _mdgriffith$elm_style_animation$Animation$iePrefix, propName),
						_1: propValue
					},
					_1: {
						ctor: '::',
						_0: {
							ctor: '_Tuple2',
							_0: A2(_elm_lang$core$Basics_ops['++'], _mdgriffith$elm_style_animation$Animation$webkitPrefix, propName),
							_1: propValue
						},
						_1: {ctor: '[]'}
					}
				}
			};
		case 'filter':
			return {
				ctor: '::',
				_0: stylePair,
				_1: {
					ctor: '::',
					_0: {
						ctor: '_Tuple2',
						_0: A2(_elm_lang$core$Basics_ops['++'], _mdgriffith$elm_style_animation$Animation$iePrefix, propName),
						_1: propValue
					},
					_1: {
						ctor: '::',
						_0: {
							ctor: '_Tuple2',
							_0: A2(_elm_lang$core$Basics_ops['++'], _mdgriffith$elm_style_animation$Animation$webkitPrefix, propName),
							_1: propValue
						},
						_1: {ctor: '[]'}
					}
				}
			};
		default:
			return {
				ctor: '::',
				_0: stylePair,
				_1: {ctor: '[]'}
			};
	}
};
var _mdgriffith$elm_style_animation$Animation$isFilter = function (prop) {
	return A2(
		_elm_lang$core$List$member,
		_mdgriffith$elm_style_animation$Animation_Model$propertyName(prop),
		{
			ctor: '::',
			_0: 'filter-url',
			_1: {
				ctor: '::',
				_0: 'blur',
				_1: {
					ctor: '::',
					_0: 'brightness',
					_1: {
						ctor: '::',
						_0: 'contrast',
						_1: {
							ctor: '::',
							_0: 'grayscale',
							_1: {
								ctor: '::',
								_0: 'hue-rotate',
								_1: {
									ctor: '::',
									_0: 'invert',
									_1: {
										ctor: '::',
										_0: 'saturate',
										_1: {
											ctor: '::',
											_0: 'sepia',
											_1: {
												ctor: '::',
												_0: 'drop-shadow',
												_1: {ctor: '[]'}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		});
};
var _mdgriffith$elm_style_animation$Animation$render3dRotation = function (prop) {
	var _p35 = prop;
	if (_p35.ctor === 'Property3') {
		var _p38 = _p35._3;
		var _p37 = _p35._2;
		var _p36 = _p35._1;
		return A2(
			_elm_lang$core$Basics_ops['++'],
			'rotateX(',
			A2(
				_elm_lang$core$Basics_ops['++'],
				_elm_lang$core$Basics$toString(_p36.position),
				A2(
					_elm_lang$core$Basics_ops['++'],
					_p36.unit,
					A2(
						_elm_lang$core$Basics_ops['++'],
						') rotateY(',
						A2(
							_elm_lang$core$Basics_ops['++'],
							_elm_lang$core$Basics$toString(_p37.position),
							A2(
								_elm_lang$core$Basics_ops['++'],
								_p37.unit,
								A2(
									_elm_lang$core$Basics_ops['++'],
									') rotateZ(',
									A2(
										_elm_lang$core$Basics_ops['++'],
										_elm_lang$core$Basics$toString(_p38.position),
										A2(_elm_lang$core$Basics_ops['++'], _p38.unit, ')')))))))));
	} else {
		return '';
	}
};
var _mdgriffith$elm_style_animation$Animation$isTransformation = function (prop) {
	return A2(
		_elm_lang$core$List$member,
		_mdgriffith$elm_style_animation$Animation_Model$propertyName(prop),
		{
			ctor: '::',
			_0: 'rotate',
			_1: {
				ctor: '::',
				_0: 'rotateX',
				_1: {
					ctor: '::',
					_0: 'rotateY',
					_1: {
						ctor: '::',
						_0: 'rotateZ',
						_1: {
							ctor: '::',
							_0: 'rotate3d',
							_1: {
								ctor: '::',
								_0: 'translate',
								_1: {
									ctor: '::',
									_0: 'translate3d',
									_1: {
										ctor: '::',
										_0: 'scale',
										_1: {
											ctor: '::',
											_0: 'scale3d',
											_1: {ctor: '[]'}
										}
									}
								}
							}
						}
					}
				}
			}
		});
};
var _mdgriffith$elm_style_animation$Animation$renderAttrs = function (prop) {
	if (A2(
		_elm_lang$core$String$startsWith,
		'attr:',
		_mdgriffith$elm_style_animation$Animation_Model$propertyName(prop))) {
		return _elm_lang$core$Maybe$Just(
			A2(
				_elm_lang$html$Html_Attributes$attribute,
				A2(
					_elm_lang$core$String$dropLeft,
					5,
					_mdgriffith$elm_style_animation$Animation_Model$propertyName(prop)),
				A2(_mdgriffith$elm_style_animation$Animation$propertyValue, prop, ' ')));
	} else {
		var _p39 = prop;
		switch (_p39.ctor) {
			case 'Points':
				return _elm_lang$core$Maybe$Just(
					_elm_lang$svg$Svg_Attributes$points(
						A2(_mdgriffith$elm_style_animation$Animation$propertyValue, prop, ' ')));
			case 'Path':
				return _elm_lang$core$Maybe$Just(
					_elm_lang$svg$Svg_Attributes$d(
						A2(_mdgriffith$elm_style_animation$Animation$propertyValue, prop, ' ')));
			case 'Property':
				var _p40 = _p39._0;
				switch (_p40) {
					case 'x':
						return _elm_lang$core$Maybe$Just(
							_elm_lang$svg$Svg_Attributes$x(
								A2(_mdgriffith$elm_style_animation$Animation$propertyValue, prop, ' ')));
					case 'y':
						return _elm_lang$core$Maybe$Just(
							_elm_lang$svg$Svg_Attributes$y(
								A2(_mdgriffith$elm_style_animation$Animation$propertyValue, prop, ' ')));
					case 'cx':
						return _elm_lang$core$Maybe$Just(
							_elm_lang$svg$Svg_Attributes$cx(
								A2(_mdgriffith$elm_style_animation$Animation$propertyValue, prop, ' ')));
					case 'cy':
						return _elm_lang$core$Maybe$Just(
							_elm_lang$svg$Svg_Attributes$cy(
								A2(_mdgriffith$elm_style_animation$Animation$propertyValue, prop, ' ')));
					case 'rx':
						return _elm_lang$core$Maybe$Just(
							_elm_lang$svg$Svg_Attributes$rx(
								A2(_mdgriffith$elm_style_animation$Animation$propertyValue, prop, ' ')));
					case 'ry':
						return _elm_lang$core$Maybe$Just(
							_elm_lang$svg$Svg_Attributes$ry(
								A2(_mdgriffith$elm_style_animation$Animation$propertyValue, prop, ' ')));
					case 'r':
						return _elm_lang$core$Maybe$Just(
							_elm_lang$svg$Svg_Attributes$r(
								A2(_mdgriffith$elm_style_animation$Animation$propertyValue, prop, ' ')));
					case 'offset':
						return _elm_lang$core$Maybe$Just(
							_elm_lang$svg$Svg_Attributes$offset(
								A2(_mdgriffith$elm_style_animation$Animation$propertyValue, prop, ' ')));
					default:
						return _elm_lang$core$Maybe$Nothing;
				}
			case 'Property4':
				return _elm_lang$core$Native_Utils.eq(_p39._0, 'viewBox') ? _elm_lang$core$Maybe$Just(
					_elm_lang$svg$Svg_Attributes$viewBox(
						A2(_mdgriffith$elm_style_animation$Animation$propertyValue, prop, ' '))) : _elm_lang$core$Maybe$Nothing;
			default:
				return _elm_lang$core$Maybe$Nothing;
		}
	}
};
var _mdgriffith$elm_style_animation$Animation$render = function (_p41) {
	var _p42 = _p41;
	var _p43 = A2(_elm_lang$core$List$partition, _mdgriffith$elm_style_animation$Animation$isAttr, _p42._0.style);
	var attrProps = _p43._0;
	var styleProps = _p43._1;
	var _p44 = A3(
		_elm_lang$core$List$foldl,
		F2(
			function (prop, _p45) {
				var _p46 = _p45;
				var _p49 = _p46._1;
				var _p48 = _p46._0;
				var _p47 = _p46._2;
				return _mdgriffith$elm_style_animation$Animation$isTransformation(prop) ? {
					ctor: '_Tuple3',
					_0: _p48,
					_1: A2(
						_elm_lang$core$Basics_ops['++'],
						_p49,
						{
							ctor: '::',
							_0: prop,
							_1: {ctor: '[]'}
						}),
					_2: _p47
				} : (_mdgriffith$elm_style_animation$Animation$isFilter(prop) ? {
					ctor: '_Tuple3',
					_0: _p48,
					_1: _p49,
					_2: A2(
						_elm_lang$core$Basics_ops['++'],
						_p47,
						{
							ctor: '::',
							_0: prop,
							_1: {ctor: '[]'}
						})
				} : {
					ctor: '_Tuple3',
					_0: A2(
						_elm_lang$core$Basics_ops['++'],
						_p48,
						{
							ctor: '::',
							_0: prop,
							_1: {ctor: '[]'}
						}),
					_1: _p49,
					_2: _p47
				});
			}),
		{
			ctor: '_Tuple3',
			_0: {ctor: '[]'},
			_1: {ctor: '[]'},
			_2: {ctor: '[]'}
		},
		styleProps);
	var style = _p44._0;
	var transforms = _p44._1;
	var filters = _p44._2;
	var renderedStyle = A2(
		_elm_lang$core$List$map,
		function (prop) {
			return {
				ctor: '_Tuple2',
				_0: _mdgriffith$elm_style_animation$Animation_Model$propertyName(prop),
				_1: A2(_mdgriffith$elm_style_animation$Animation$propertyValue, prop, ' ')
			};
		},
		style);
	var renderedTransforms = _elm_lang$core$List$isEmpty(transforms) ? {ctor: '[]'} : {
		ctor: '::',
		_0: {
			ctor: '_Tuple2',
			_0: 'transform',
			_1: A2(
				_elm_lang$core$String$join,
				' ',
				A2(
					_elm_lang$core$List$map,
					function (prop) {
						return _elm_lang$core$Native_Utils.eq(
							_mdgriffith$elm_style_animation$Animation_Model$propertyName(prop),
							'rotate3d') ? _mdgriffith$elm_style_animation$Animation$render3dRotation(prop) : A2(
							_elm_lang$core$Basics_ops['++'],
							_mdgriffith$elm_style_animation$Animation_Model$propertyName(prop),
							A2(
								_elm_lang$core$Basics_ops['++'],
								'(',
								A2(
									_elm_lang$core$Basics_ops['++'],
									A2(_mdgriffith$elm_style_animation$Animation$propertyValue, prop, ', '),
									')')));
					},
					transforms))
		},
		_1: {ctor: '[]'}
	};
	var renderedFilters = _elm_lang$core$List$isEmpty(filters) ? {ctor: '[]'} : {
		ctor: '::',
		_0: {
			ctor: '_Tuple2',
			_0: 'filter',
			_1: A2(
				_elm_lang$core$String$join,
				' ',
				A2(
					_elm_lang$core$List$map,
					function (prop) {
						var name = _mdgriffith$elm_style_animation$Animation_Model$propertyName(prop);
						return _elm_lang$core$Native_Utils.eq(name, 'filter-url') ? A2(
							_elm_lang$core$Basics_ops['++'],
							'url(\"',
							A2(
								_elm_lang$core$Basics_ops['++'],
								A2(_mdgriffith$elm_style_animation$Animation$propertyValue, prop, ', '),
								'\")')) : A2(
							_elm_lang$core$Basics_ops['++'],
							_mdgriffith$elm_style_animation$Animation_Model$propertyName(prop),
							A2(
								_elm_lang$core$Basics_ops['++'],
								'(',
								A2(
									_elm_lang$core$Basics_ops['++'],
									A2(_mdgriffith$elm_style_animation$Animation$propertyValue, prop, ', '),
									')')));
					},
					filters))
		},
		_1: {ctor: '[]'}
	};
	var styleAttr = _elm_lang$html$Html_Attributes$style(
		A2(
			_elm_lang$core$List$concatMap,
			_mdgriffith$elm_style_animation$Animation$prefix,
			A2(
				_elm_lang$core$Basics_ops['++'],
				renderedTransforms,
				A2(_elm_lang$core$Basics_ops['++'], renderedFilters, renderedStyle))));
	var otherAttrs = A2(_elm_lang$core$List$filterMap, _mdgriffith$elm_style_animation$Animation$renderAttrs, attrProps);
	return {ctor: '::', _0: styleAttr, _1: otherAttrs};
};
var _mdgriffith$elm_style_animation$Animation$alignStartingPoint = function (points) {
	var sums = A2(
		_elm_lang$core$List$map,
		function (_p50) {
			var _p51 = _p50;
			return _p51._0 + _p51._1;
		},
		points);
	var maybeMin = _elm_lang$core$List$minimum(sums);
	var indexOfLowestPoint = function () {
		var _p52 = maybeMin;
		if (_p52.ctor === 'Nothing') {
			return _elm_lang$core$Maybe$Nothing;
		} else {
			return _elm_lang$core$List$head(
				A2(
					_elm_lang$core$List$filterMap,
					_elm_lang$core$Basics$identity,
					A2(
						_elm_lang$core$List$indexedMap,
						F2(
							function (i, val) {
								return _elm_lang$core$Native_Utils.eq(val, _p52._0) ? _elm_lang$core$Maybe$Just(i) : _elm_lang$core$Maybe$Nothing;
							}),
						sums)));
		}
	}();
	var _p53 = indexOfLowestPoint;
	if (_p53.ctor === 'Nothing') {
		return points;
	} else {
		var _p54 = _p53._0;
		return A2(
			_elm_lang$core$Basics_ops['++'],
			A2(_elm_lang$core$List$drop, _p54, points),
			A2(_elm_lang$core$List$take, _p54, points));
	}
};
var _mdgriffith$elm_style_animation$Animation$close = _mdgriffith$elm_style_animation$Animation_Model$Close;
var _mdgriffith$elm_style_animation$Animation$path = function (commands) {
	return _mdgriffith$elm_style_animation$Animation_Model$Path(commands);
};
var _mdgriffith$elm_style_animation$Animation$display = function (mode) {
	return A2(
		_mdgriffith$elm_style_animation$Animation_Model$ExactProperty,
		'display',
		_mdgriffith$elm_style_animation$Animation$displayModeName(mode));
};
var _mdgriffith$elm_style_animation$Animation$exactly = F2(
	function (name, value) {
		return A2(_mdgriffith$elm_style_animation$Animation_Model$ExactProperty, name, value);
	});
var _mdgriffith$elm_style_animation$Animation$filterUrl = function (url) {
	return A2(_mdgriffith$elm_style_animation$Animation$exactly, 'filter-url', url);
};
var _mdgriffith$elm_style_animation$Animation$initMotion = F2(
	function (position, unit) {
		return {
			position: position,
			velocity: 0,
			target: position,
			unit: unit,
			interpolation: _mdgriffith$elm_style_animation$Animation_Model$Spring(
				{stiffness: 170, damping: 26}),
			interpolationOverride: _elm_lang$core$Maybe$Nothing
		};
	});
var _mdgriffith$elm_style_animation$Animation$length = F3(
	function (name, x, unit) {
		return A2(
			_mdgriffith$elm_style_animation$Animation_Model$Property,
			name,
			A2(_mdgriffith$elm_style_animation$Animation$initMotion, x, unit));
	});
var _mdgriffith$elm_style_animation$Animation$strokeWidth = function (x) {
	return A3(_mdgriffith$elm_style_animation$Animation$length, 'stroke-width', x, '');
};
var _mdgriffith$elm_style_animation$Animation$length2 = F3(
	function (name, _p56, _p55) {
		var _p57 = _p56;
		var _p58 = _p55;
		return A3(
			_mdgriffith$elm_style_animation$Animation_Model$Property2,
			name,
			A2(_mdgriffith$elm_style_animation$Animation$initMotion, _p57._0, _p57._1),
			A2(_mdgriffith$elm_style_animation$Animation$initMotion, _p58._0, _p58._1));
	});
var _mdgriffith$elm_style_animation$Animation$attr2 = F3(
	function (name, value1, value2) {
		return A3(
			_mdgriffith$elm_style_animation$Animation$length2,
			A2(_elm_lang$core$Basics_ops['++'], 'attr:', name),
			value1,
			value2);
	});
var _mdgriffith$elm_style_animation$Animation$custom2 = F3(
	function (name, value, unit) {
		return A3(_mdgriffith$elm_style_animation$Animation$length2, name, value, unit);
	});
var _mdgriffith$elm_style_animation$Animation$length3 = F4(
	function (name, _p61, _p60, _p59) {
		var _p62 = _p61;
		var _p63 = _p60;
		var _p64 = _p59;
		return A4(
			_mdgriffith$elm_style_animation$Animation_Model$Property3,
			name,
			A2(_mdgriffith$elm_style_animation$Animation$initMotion, _p62._0, _p62._1),
			A2(_mdgriffith$elm_style_animation$Animation$initMotion, _p63._0, _p63._1),
			A2(_mdgriffith$elm_style_animation$Animation$initMotion, _p64._0, _p64._1));
	});
var _mdgriffith$elm_style_animation$Animation$attr3 = F4(
	function (name, value1, value2, value3) {
		return A4(
			_mdgriffith$elm_style_animation$Animation$length3,
			A2(_elm_lang$core$Basics_ops['++'], 'attr:', name),
			value1,
			value2,
			value3);
	});
var _mdgriffith$elm_style_animation$Animation$rotate3d = F3(
	function (_p67, _p66, _p65) {
		var _p68 = _p67;
		var _p69 = _p66;
		var _p70 = _p65;
		return A4(
			_mdgriffith$elm_style_animation$Animation$length3,
			'rotate3d',
			{ctor: '_Tuple2', _0: _p68._0, _1: 'rad'},
			{ctor: '_Tuple2', _0: _p69._0, _1: 'rad'},
			{ctor: '_Tuple2', _0: _p70._0, _1: 'rad'});
	});
var _mdgriffith$elm_style_animation$Animation$length4 = F5(
	function (name, _p74, _p73, _p72, _p71) {
		var _p75 = _p74;
		var _p76 = _p73;
		var _p77 = _p72;
		var _p78 = _p71;
		return A5(
			_mdgriffith$elm_style_animation$Animation_Model$Property4,
			name,
			A2(_mdgriffith$elm_style_animation$Animation$initMotion, _p75._0, _p75._1),
			A2(_mdgriffith$elm_style_animation$Animation$initMotion, _p76._0, _p76._1),
			A2(_mdgriffith$elm_style_animation$Animation$initMotion, _p77._0, _p77._1),
			A2(_mdgriffith$elm_style_animation$Animation$initMotion, _p78._0, _p78._1));
	});
var _mdgriffith$elm_style_animation$Animation$attr4 = F5(
	function (name, value1, value2, value3, value4) {
		return A5(
			_mdgriffith$elm_style_animation$Animation$length4,
			A2(_elm_lang$core$Basics_ops['++'], 'attr:', name),
			value1,
			value2,
			value3,
			value4);
	});
var _mdgriffith$elm_style_animation$Animation$viewBox = F4(
	function (w, x, y, z) {
		return A5(
			_mdgriffith$elm_style_animation$Animation$length4,
			'viewBox',
			{ctor: '_Tuple2', _0: w, _1: ''},
			{ctor: '_Tuple2', _0: x, _1: ''},
			{ctor: '_Tuple2', _0: y, _1: ''},
			{ctor: '_Tuple2', _0: z, _1: ''});
	});
var _mdgriffith$elm_style_animation$Animation$attr = F3(
	function (name, value, unit) {
		return A2(
			_mdgriffith$elm_style_animation$Animation_Model$Property,
			A2(_elm_lang$core$Basics_ops['++'], 'attr:', name),
			A2(_mdgriffith$elm_style_animation$Animation$initMotion, value, unit));
	});
var _mdgriffith$elm_style_animation$Animation$attrColor = F2(
	function (name, color) {
		var _p79 = _elm_lang$core$Color$toRgb(color);
		var red = _p79.red;
		var green = _p79.green;
		var blue = _p79.blue;
		var alpha = _p79.alpha;
		return A5(
			_mdgriffith$elm_style_animation$Animation_Model$ColorProperty,
			A2(_elm_lang$core$Basics_ops['++'], 'attr:', name),
			A2(
				_mdgriffith$elm_style_animation$Animation$initMotion,
				_elm_lang$core$Basics$toFloat(red),
				''),
			A2(
				_mdgriffith$elm_style_animation$Animation$initMotion,
				_elm_lang$core$Basics$toFloat(green),
				''),
			A2(
				_mdgriffith$elm_style_animation$Animation$initMotion,
				_elm_lang$core$Basics$toFloat(blue),
				''),
			A2(_mdgriffith$elm_style_animation$Animation$initMotion, alpha, ''));
	});
var _mdgriffith$elm_style_animation$Animation$custom = F3(
	function (name, value, unit) {
		return A2(
			_mdgriffith$elm_style_animation$Animation_Model$Property,
			name,
			A2(_mdgriffith$elm_style_animation$Animation$initMotion, value, unit));
	});
var _mdgriffith$elm_style_animation$Animation$opacity = function (x) {
	return A3(_mdgriffith$elm_style_animation$Animation$custom, 'opacity', x, '');
};
var _mdgriffith$elm_style_animation$Animation$scale = function (x) {
	return A3(_mdgriffith$elm_style_animation$Animation$custom, 'scale', x, '');
};
var _mdgriffith$elm_style_animation$Animation$x = function (x) {
	return A3(_mdgriffith$elm_style_animation$Animation$custom, 'x', x, '');
};
var _mdgriffith$elm_style_animation$Animation$y = function (y) {
	return A3(_mdgriffith$elm_style_animation$Animation$custom, 'y', y, '');
};
var _mdgriffith$elm_style_animation$Animation$cx = function (x) {
	return A3(_mdgriffith$elm_style_animation$Animation$custom, 'cx', x, '');
};
var _mdgriffith$elm_style_animation$Animation$cy = function (y) {
	return A3(_mdgriffith$elm_style_animation$Animation$custom, 'cy', y, '');
};
var _mdgriffith$elm_style_animation$Animation$radius = function (r) {
	return A3(_mdgriffith$elm_style_animation$Animation$custom, 'r', r, '');
};
var _mdgriffith$elm_style_animation$Animation$radiusX = function (rx) {
	return A3(_mdgriffith$elm_style_animation$Animation$custom, 'rx', rx, '');
};
var _mdgriffith$elm_style_animation$Animation$radiusY = function (ry) {
	return A3(_mdgriffith$elm_style_animation$Animation$custom, 'ry', ry, '');
};
var _mdgriffith$elm_style_animation$Animation$brightness = function (x) {
	return A3(_mdgriffith$elm_style_animation$Animation$custom, 'brightness', x, '%');
};
var _mdgriffith$elm_style_animation$Animation$contrast = function (x) {
	return A3(_mdgriffith$elm_style_animation$Animation$custom, 'contrast', x, '%');
};
var _mdgriffith$elm_style_animation$Animation$grayscale = function (x) {
	return A3(_mdgriffith$elm_style_animation$Animation$custom, 'grayscale', x, '%');
};
var _mdgriffith$elm_style_animation$Animation$greyscale = function (x) {
	return _mdgriffith$elm_style_animation$Animation$grayscale(x);
};
var _mdgriffith$elm_style_animation$Animation$invert = function (x) {
	return A3(_mdgriffith$elm_style_animation$Animation$custom, 'invert', x, '%');
};
var _mdgriffith$elm_style_animation$Animation$saturate = function (x) {
	return A3(_mdgriffith$elm_style_animation$Animation$custom, 'saturate', x, '%');
};
var _mdgriffith$elm_style_animation$Animation$sepia = function (x) {
	return A3(_mdgriffith$elm_style_animation$Animation$custom, 'sepia', x, '%');
};
var _mdgriffith$elm_style_animation$Animation$offset = function (value) {
	return A3(_mdgriffith$elm_style_animation$Animation$custom, 'offset', value, '');
};
var _mdgriffith$elm_style_animation$Animation$customColor = F2(
	function (name, color) {
		var _p80 = _elm_lang$core$Color$toRgb(color);
		var red = _p80.red;
		var green = _p80.green;
		var blue = _p80.blue;
		var alpha = _p80.alpha;
		return A5(
			_mdgriffith$elm_style_animation$Animation_Model$ColorProperty,
			name,
			A2(
				_mdgriffith$elm_style_animation$Animation$initMotion,
				_elm_lang$core$Basics$toFloat(red),
				''),
			A2(
				_mdgriffith$elm_style_animation$Animation$initMotion,
				_elm_lang$core$Basics$toFloat(green),
				''),
			A2(
				_mdgriffith$elm_style_animation$Animation$initMotion,
				_elm_lang$core$Basics$toFloat(blue),
				''),
			A2(_mdgriffith$elm_style_animation$Animation$initMotion, alpha, ''));
	});
var _mdgriffith$elm_style_animation$Animation$color = function (c) {
	return A2(_mdgriffith$elm_style_animation$Animation$customColor, 'color', c);
};
var _mdgriffith$elm_style_animation$Animation$backgroundColor = function (c) {
	return A2(_mdgriffith$elm_style_animation$Animation$customColor, 'background-color', c);
};
var _mdgriffith$elm_style_animation$Animation$borderColor = function (c) {
	return A2(_mdgriffith$elm_style_animation$Animation$customColor, 'border-color', c);
};
var _mdgriffith$elm_style_animation$Animation$fill = function (color) {
	return A2(_mdgriffith$elm_style_animation$Animation$customColor, 'fill', color);
};
var _mdgriffith$elm_style_animation$Animation$stroke = function (color) {
	return A2(_mdgriffith$elm_style_animation$Animation$customColor, 'stroke', color);
};
var _mdgriffith$elm_style_animation$Animation$stopColor = function (color) {
	return A2(_mdgriffith$elm_style_animation$Animation$customColor, 'stop-color', color);
};
var _mdgriffith$elm_style_animation$Animation$scale3d = F3(
	function (x, y, z) {
		return A4(
			_mdgriffith$elm_style_animation$Animation_Model$Property3,
			'scale3d',
			A2(_mdgriffith$elm_style_animation$Animation$initMotion, x, ''),
			A2(_mdgriffith$elm_style_animation$Animation$initMotion, y, ''),
			A2(_mdgriffith$elm_style_animation$Animation$initMotion, z, ''));
	});
var _mdgriffith$elm_style_animation$Animation$rotate = function (_p81) {
	var _p82 = _p81;
	return A2(
		_mdgriffith$elm_style_animation$Animation_Model$AngleProperty,
		'rotate',
		A2(_mdgriffith$elm_style_animation$Animation$initMotion, _p82._0, 'rad'));
};
var _mdgriffith$elm_style_animation$Animation$textShadow = function (shade) {
	var _p83 = _elm_lang$core$Color$toRgb(shade.color);
	var red = _p83.red;
	var green = _p83.green;
	var blue = _p83.blue;
	var alpha = _p83.alpha;
	return A3(
		_mdgriffith$elm_style_animation$Animation_Model$ShadowProperty,
		'text-shadow',
		false,
		{
			offsetX: A2(_mdgriffith$elm_style_animation$Animation$initMotion, shade.offsetX, 'px'),
			offsetY: A2(_mdgriffith$elm_style_animation$Animation$initMotion, shade.offsetY, 'px'),
			size: A2(_mdgriffith$elm_style_animation$Animation$initMotion, shade.size, 'px'),
			blur: A2(_mdgriffith$elm_style_animation$Animation$initMotion, shade.blur, 'px'),
			red: A2(
				_mdgriffith$elm_style_animation$Animation$initMotion,
				_elm_lang$core$Basics$toFloat(red),
				'px'),
			green: A2(
				_mdgriffith$elm_style_animation$Animation$initMotion,
				_elm_lang$core$Basics$toFloat(green),
				'px'),
			blue: A2(
				_mdgriffith$elm_style_animation$Animation$initMotion,
				_elm_lang$core$Basics$toFloat(blue),
				'px'),
			alpha: A2(_mdgriffith$elm_style_animation$Animation$initMotion, alpha, 'px')
		});
};
var _mdgriffith$elm_style_animation$Animation$shadow = function (shade) {
	var _p84 = _elm_lang$core$Color$toRgb(shade.color);
	var red = _p84.red;
	var green = _p84.green;
	var blue = _p84.blue;
	var alpha = _p84.alpha;
	return A3(
		_mdgriffith$elm_style_animation$Animation_Model$ShadowProperty,
		'box-shadow',
		false,
		{
			offsetX: A2(_mdgriffith$elm_style_animation$Animation$initMotion, shade.offsetX, 'px'),
			offsetY: A2(_mdgriffith$elm_style_animation$Animation$initMotion, shade.offsetY, 'px'),
			size: A2(_mdgriffith$elm_style_animation$Animation$initMotion, shade.size, 'px'),
			blur: A2(_mdgriffith$elm_style_animation$Animation$initMotion, shade.blur, 'px'),
			red: A2(
				_mdgriffith$elm_style_animation$Animation$initMotion,
				_elm_lang$core$Basics$toFloat(red),
				'px'),
			green: A2(
				_mdgriffith$elm_style_animation$Animation$initMotion,
				_elm_lang$core$Basics$toFloat(green),
				'px'),
			blue: A2(
				_mdgriffith$elm_style_animation$Animation$initMotion,
				_elm_lang$core$Basics$toFloat(blue),
				'px'),
			alpha: A2(_mdgriffith$elm_style_animation$Animation$initMotion, alpha, 'px')
		});
};
var _mdgriffith$elm_style_animation$Animation$insetShadow = function (shade) {
	var _p85 = _elm_lang$core$Color$toRgb(shade.color);
	var red = _p85.red;
	var green = _p85.green;
	var blue = _p85.blue;
	var alpha = _p85.alpha;
	return A3(
		_mdgriffith$elm_style_animation$Animation_Model$ShadowProperty,
		'box-shadow',
		true,
		{
			offsetX: A2(_mdgriffith$elm_style_animation$Animation$initMotion, shade.offsetX, 'px'),
			offsetY: A2(_mdgriffith$elm_style_animation$Animation$initMotion, shade.offsetY, 'px'),
			size: A2(_mdgriffith$elm_style_animation$Animation$initMotion, shade.size, 'px'),
			blur: A2(_mdgriffith$elm_style_animation$Animation$initMotion, shade.blur, 'px'),
			red: A2(
				_mdgriffith$elm_style_animation$Animation$initMotion,
				_elm_lang$core$Basics$toFloat(red),
				'px'),
			green: A2(
				_mdgriffith$elm_style_animation$Animation$initMotion,
				_elm_lang$core$Basics$toFloat(green),
				'px'),
			blue: A2(
				_mdgriffith$elm_style_animation$Animation$initMotion,
				_elm_lang$core$Basics$toFloat(blue),
				'px'),
			alpha: A2(_mdgriffith$elm_style_animation$Animation$initMotion, alpha, 'px')
		});
};
var _mdgriffith$elm_style_animation$Animation$move = F2(
	function (x, y) {
		return A2(
			_mdgriffith$elm_style_animation$Animation_Model$Move,
			A2(_mdgriffith$elm_style_animation$Animation$initMotion, x, ''),
			A2(_mdgriffith$elm_style_animation$Animation$initMotion, y, ''));
	});
var _mdgriffith$elm_style_animation$Animation$moveTo = F2(
	function (x, y) {
		return A2(
			_mdgriffith$elm_style_animation$Animation_Model$MoveTo,
			A2(_mdgriffith$elm_style_animation$Animation$initMotion, x, ''),
			A2(_mdgriffith$elm_style_animation$Animation$initMotion, y, ''));
	});
var _mdgriffith$elm_style_animation$Animation$line = F2(
	function (x, y) {
		return A2(
			_mdgriffith$elm_style_animation$Animation_Model$Line,
			A2(_mdgriffith$elm_style_animation$Animation$initMotion, x, ''),
			A2(_mdgriffith$elm_style_animation$Animation$initMotion, y, ''));
	});
var _mdgriffith$elm_style_animation$Animation$lineTo = F2(
	function (x, y) {
		return A2(
			_mdgriffith$elm_style_animation$Animation_Model$LineTo,
			A2(_mdgriffith$elm_style_animation$Animation$initMotion, x, ''),
			A2(_mdgriffith$elm_style_animation$Animation$initMotion, y, ''));
	});
var _mdgriffith$elm_style_animation$Animation$horizontal = function (x) {
	return _mdgriffith$elm_style_animation$Animation_Model$Horizontal(
		A2(_mdgriffith$elm_style_animation$Animation$initMotion, x, ''));
};
var _mdgriffith$elm_style_animation$Animation$horizontalTo = function (x) {
	return _mdgriffith$elm_style_animation$Animation_Model$HorizontalTo(
		A2(_mdgriffith$elm_style_animation$Animation$initMotion, x, ''));
};
var _mdgriffith$elm_style_animation$Animation$vertical = function (x) {
	return _mdgriffith$elm_style_animation$Animation_Model$Vertical(
		A2(_mdgriffith$elm_style_animation$Animation$initMotion, x, ''));
};
var _mdgriffith$elm_style_animation$Animation$verticalTo = function (x) {
	return _mdgriffith$elm_style_animation$Animation_Model$VerticalTo(
		A2(_mdgriffith$elm_style_animation$Animation$initMotion, x, ''));
};
var _mdgriffith$elm_style_animation$Animation$curve2 = function (_p86) {
	var _p87 = _p86;
	var _p90 = _p87.point;
	var _p89 = _p87.control2;
	var _p88 = _p87.control1;
	return _mdgriffith$elm_style_animation$Animation_Model$Curve(
		{
			control1: {
				ctor: '_Tuple2',
				_0: A2(
					_mdgriffith$elm_style_animation$Animation$initMotion,
					_elm_lang$core$Tuple$first(_p88),
					''),
				_1: A2(
					_mdgriffith$elm_style_animation$Animation$initMotion,
					_elm_lang$core$Tuple$second(_p88),
					'')
			},
			control2: {
				ctor: '_Tuple2',
				_0: A2(
					_mdgriffith$elm_style_animation$Animation$initMotion,
					_elm_lang$core$Tuple$first(_p89),
					''),
				_1: A2(
					_mdgriffith$elm_style_animation$Animation$initMotion,
					_elm_lang$core$Tuple$second(_p89),
					'')
			},
			point: {
				ctor: '_Tuple2',
				_0: A2(
					_mdgriffith$elm_style_animation$Animation$initMotion,
					_elm_lang$core$Tuple$first(_p90),
					''),
				_1: A2(
					_mdgriffith$elm_style_animation$Animation$initMotion,
					_elm_lang$core$Tuple$second(_p90),
					'')
			}
		});
};
var _mdgriffith$elm_style_animation$Animation$curve2To = function (_p91) {
	var _p92 = _p91;
	var _p95 = _p92.point;
	var _p94 = _p92.control2;
	var _p93 = _p92.control1;
	return _mdgriffith$elm_style_animation$Animation_Model$CurveTo(
		{
			control1: {
				ctor: '_Tuple2',
				_0: A2(
					_mdgriffith$elm_style_animation$Animation$initMotion,
					_elm_lang$core$Tuple$first(_p93),
					''),
				_1: A2(
					_mdgriffith$elm_style_animation$Animation$initMotion,
					_elm_lang$core$Tuple$second(_p93),
					'')
			},
			control2: {
				ctor: '_Tuple2',
				_0: A2(
					_mdgriffith$elm_style_animation$Animation$initMotion,
					_elm_lang$core$Tuple$first(_p94),
					''),
				_1: A2(
					_mdgriffith$elm_style_animation$Animation$initMotion,
					_elm_lang$core$Tuple$second(_p94),
					'')
			},
			point: {
				ctor: '_Tuple2',
				_0: A2(
					_mdgriffith$elm_style_animation$Animation$initMotion,
					_elm_lang$core$Tuple$first(_p95),
					''),
				_1: A2(
					_mdgriffith$elm_style_animation$Animation$initMotion,
					_elm_lang$core$Tuple$second(_p95),
					'')
			}
		});
};
var _mdgriffith$elm_style_animation$Animation$curve = function (_p96) {
	var _p97 = _p96;
	var _p99 = _p97.point;
	var _p98 = _p97.control;
	return _mdgriffith$elm_style_animation$Animation_Model$Quadratic(
		{
			control: {
				ctor: '_Tuple2',
				_0: A2(
					_mdgriffith$elm_style_animation$Animation$initMotion,
					_elm_lang$core$Tuple$first(_p98),
					''),
				_1: A2(
					_mdgriffith$elm_style_animation$Animation$initMotion,
					_elm_lang$core$Tuple$second(_p98),
					'')
			},
			point: {
				ctor: '_Tuple2',
				_0: A2(
					_mdgriffith$elm_style_animation$Animation$initMotion,
					_elm_lang$core$Tuple$first(_p99),
					''),
				_1: A2(
					_mdgriffith$elm_style_animation$Animation$initMotion,
					_elm_lang$core$Tuple$second(_p99),
					'')
			}
		});
};
var _mdgriffith$elm_style_animation$Animation$curveTo = function (_p100) {
	var _p101 = _p100;
	var _p103 = _p101.point;
	var _p102 = _p101.control;
	return _mdgriffith$elm_style_animation$Animation_Model$QuadraticTo(
		{
			control: {
				ctor: '_Tuple2',
				_0: A2(
					_mdgriffith$elm_style_animation$Animation$initMotion,
					_elm_lang$core$Tuple$first(_p102),
					''),
				_1: A2(
					_mdgriffith$elm_style_animation$Animation$initMotion,
					_elm_lang$core$Tuple$second(_p102),
					'')
			},
			point: {
				ctor: '_Tuple2',
				_0: A2(
					_mdgriffith$elm_style_animation$Animation$initMotion,
					_elm_lang$core$Tuple$first(_p103),
					''),
				_1: A2(
					_mdgriffith$elm_style_animation$Animation$initMotion,
					_elm_lang$core$Tuple$second(_p103),
					'')
			}
		});
};
var _mdgriffith$elm_style_animation$Animation$arc = function (arc) {
	return arc.clockwise ? _mdgriffith$elm_style_animation$Animation_Model$ClockwiseArc(
		{
			x: A2(_mdgriffith$elm_style_animation$Animation$initMotion, arc.x, ''),
			y: A2(_mdgriffith$elm_style_animation$Animation$initMotion, arc.y, ''),
			radius: A2(_mdgriffith$elm_style_animation$Animation$initMotion, arc.radius, ''),
			startAngle: A2(_mdgriffith$elm_style_animation$Animation$initMotion, arc.startAngle, ''),
			endAngle: A2(_mdgriffith$elm_style_animation$Animation$initMotion, arc.endAngle, '')
		}) : _mdgriffith$elm_style_animation$Animation_Model$AntiClockwiseArc(
		{
			x: A2(_mdgriffith$elm_style_animation$Animation$initMotion, arc.x, ''),
			y: A2(_mdgriffith$elm_style_animation$Animation$initMotion, arc.y, ''),
			radius: A2(_mdgriffith$elm_style_animation$Animation$initMotion, arc.radius, ''),
			startAngle: A2(_mdgriffith$elm_style_animation$Animation$initMotion, arc.startAngle, ''),
			endAngle: A2(_mdgriffith$elm_style_animation$Animation$initMotion, arc.endAngle, '')
		});
};
var _mdgriffith$elm_style_animation$Animation$hueRotate = function (_p104) {
	var _p105 = _p104;
	return A2(
		_mdgriffith$elm_style_animation$Animation_Model$AngleProperty,
		'hue-rotate',
		A2(_mdgriffith$elm_style_animation$Animation$initMotion, _p105._0, 'rad'));
};
var _mdgriffith$elm_style_animation$Animation$dropShadow = function (shade) {
	var _p106 = _elm_lang$core$Color$toRgb(shade.color);
	var red = _p106.red;
	var green = _p106.green;
	var blue = _p106.blue;
	var alpha = _p106.alpha;
	return A3(
		_mdgriffith$elm_style_animation$Animation_Model$ShadowProperty,
		'drop-shadow',
		false,
		{
			offsetX: A2(_mdgriffith$elm_style_animation$Animation$initMotion, shade.offsetX, 'px'),
			offsetY: A2(_mdgriffith$elm_style_animation$Animation$initMotion, shade.offsetY, 'px'),
			size: A2(_mdgriffith$elm_style_animation$Animation$initMotion, shade.size, 'px'),
			blur: A2(_mdgriffith$elm_style_animation$Animation$initMotion, shade.blur, 'px'),
			red: A2(
				_mdgriffith$elm_style_animation$Animation$initMotion,
				_elm_lang$core$Basics$toFloat(red),
				'px'),
			green: A2(
				_mdgriffith$elm_style_animation$Animation$initMotion,
				_elm_lang$core$Basics$toFloat(green),
				'px'),
			blue: A2(
				_mdgriffith$elm_style_animation$Animation$initMotion,
				_elm_lang$core$Basics$toFloat(blue),
				'px'),
			alpha: A2(_mdgriffith$elm_style_animation$Animation$initMotion, alpha, 'px')
		});
};
var _mdgriffith$elm_style_animation$Animation$points = function (pnts) {
	return _mdgriffith$elm_style_animation$Animation_Model$Points(
		A2(
			_elm_lang$core$List$map,
			function (_p107) {
				var _p108 = _p107;
				return {
					ctor: '_Tuple2',
					_0: A2(_mdgriffith$elm_style_animation$Animation$initMotion, _p108._0, ''),
					_1: A2(_mdgriffith$elm_style_animation$Animation$initMotion, _p108._1, '')
				};
			},
			_mdgriffith$elm_style_animation$Animation$alignStartingPoint(pnts)));
};
var _mdgriffith$elm_style_animation$Animation$lengthUnitName = function (unit) {
	var _p109 = unit;
	switch (_p109.ctor) {
		case 'NoUnit':
			return '';
		case 'Px':
			return 'px';
		case 'Percent':
			return '%';
		case 'Rem':
			return 'rem';
		case 'Em':
			return 'em';
		case 'Ex':
			return 'ex';
		case 'Ch':
			return 'ch';
		case 'Vh':
			return 'vh';
		case 'Vw':
			return 'vw';
		case 'Vmin':
			return 'vmin';
		case 'Vmax':
			return 'vmax';
		case 'Mm':
			return 'mm';
		case 'Cm':
			return 'cm';
		case 'In':
			return 'in';
		case 'Pt':
			return 'pt';
		default:
			return 'pc';
	}
};
var _mdgriffith$elm_style_animation$Animation$height = function (_p110) {
	var _p111 = _p110;
	return A3(
		_mdgriffith$elm_style_animation$Animation$length,
		'height',
		_p111._0,
		_mdgriffith$elm_style_animation$Animation$lengthUnitName(_p111._1));
};
var _mdgriffith$elm_style_animation$Animation$width = function (_p112) {
	var _p113 = _p112;
	return A3(
		_mdgriffith$elm_style_animation$Animation$length,
		'width',
		_p113._0,
		_mdgriffith$elm_style_animation$Animation$lengthUnitName(_p113._1));
};
var _mdgriffith$elm_style_animation$Animation$left = function (_p114) {
	var _p115 = _p114;
	return A3(
		_mdgriffith$elm_style_animation$Animation$length,
		'left',
		_p115._0,
		_mdgriffith$elm_style_animation$Animation$lengthUnitName(_p115._1));
};
var _mdgriffith$elm_style_animation$Animation$top = function (_p116) {
	var _p117 = _p116;
	return A3(
		_mdgriffith$elm_style_animation$Animation$length,
		'top',
		_p117._0,
		_mdgriffith$elm_style_animation$Animation$lengthUnitName(_p117._1));
};
var _mdgriffith$elm_style_animation$Animation$right = function (_p118) {
	var _p119 = _p118;
	return A3(
		_mdgriffith$elm_style_animation$Animation$length,
		'right',
		_p119._0,
		_mdgriffith$elm_style_animation$Animation$lengthUnitName(_p119._1));
};
var _mdgriffith$elm_style_animation$Animation$bottom = function (_p120) {
	var _p121 = _p120;
	return A3(
		_mdgriffith$elm_style_animation$Animation$length,
		'bottom',
		_p121._0,
		_mdgriffith$elm_style_animation$Animation$lengthUnitName(_p121._1));
};
var _mdgriffith$elm_style_animation$Animation$maxHeight = function (_p122) {
	var _p123 = _p122;
	return A3(
		_mdgriffith$elm_style_animation$Animation$length,
		'max-height',
		_p123._0,
		_mdgriffith$elm_style_animation$Animation$lengthUnitName(_p123._1));
};
var _mdgriffith$elm_style_animation$Animation$maxWidth = function (_p124) {
	var _p125 = _p124;
	return A3(
		_mdgriffith$elm_style_animation$Animation$length,
		'max-width',
		_p125._0,
		_mdgriffith$elm_style_animation$Animation$lengthUnitName(_p125._1));
};
var _mdgriffith$elm_style_animation$Animation$minHeight = function (_p126) {
	var _p127 = _p126;
	return A3(
		_mdgriffith$elm_style_animation$Animation$length,
		'min-height',
		_p127._0,
		_mdgriffith$elm_style_animation$Animation$lengthUnitName(_p127._1));
};
var _mdgriffith$elm_style_animation$Animation$minWidth = function (_p128) {
	var _p129 = _p128;
	return A3(
		_mdgriffith$elm_style_animation$Animation$length,
		'min-width',
		_p129._0,
		_mdgriffith$elm_style_animation$Animation$lengthUnitName(_p129._1));
};
var _mdgriffith$elm_style_animation$Animation$padding = function (_p130) {
	var _p131 = _p130;
	return A3(
		_mdgriffith$elm_style_animation$Animation$length,
		'padding',
		_p131._0,
		_mdgriffith$elm_style_animation$Animation$lengthUnitName(_p131._1));
};
var _mdgriffith$elm_style_animation$Animation$paddingLeft = function (_p132) {
	var _p133 = _p132;
	return A3(
		_mdgriffith$elm_style_animation$Animation$length,
		'padding-left',
		_p133._0,
		_mdgriffith$elm_style_animation$Animation$lengthUnitName(_p133._1));
};
var _mdgriffith$elm_style_animation$Animation$paddingRight = function (_p134) {
	var _p135 = _p134;
	return A3(
		_mdgriffith$elm_style_animation$Animation$length,
		'padding-right',
		_p135._0,
		_mdgriffith$elm_style_animation$Animation$lengthUnitName(_p135._1));
};
var _mdgriffith$elm_style_animation$Animation$paddingTop = function (_p136) {
	var _p137 = _p136;
	return A3(
		_mdgriffith$elm_style_animation$Animation$length,
		'padding-top',
		_p137._0,
		_mdgriffith$elm_style_animation$Animation$lengthUnitName(_p137._1));
};
var _mdgriffith$elm_style_animation$Animation$paddingBottom = function (_p138) {
	var _p139 = _p138;
	return A3(
		_mdgriffith$elm_style_animation$Animation$length,
		'padding-bottom',
		_p139._0,
		_mdgriffith$elm_style_animation$Animation$lengthUnitName(_p139._1));
};
var _mdgriffith$elm_style_animation$Animation$margin = function (_p140) {
	var _p141 = _p140;
	return A3(
		_mdgriffith$elm_style_animation$Animation$length,
		'margin',
		_p141._0,
		_mdgriffith$elm_style_animation$Animation$lengthUnitName(_p141._1));
};
var _mdgriffith$elm_style_animation$Animation$marginLeft = function (_p142) {
	var _p143 = _p142;
	return A3(
		_mdgriffith$elm_style_animation$Animation$length,
		'margin-left',
		_p143._0,
		_mdgriffith$elm_style_animation$Animation$lengthUnitName(_p143._1));
};
var _mdgriffith$elm_style_animation$Animation$marginRight = function (_p144) {
	var _p145 = _p144;
	return A3(
		_mdgriffith$elm_style_animation$Animation$length,
		'margin-right',
		_p145._0,
		_mdgriffith$elm_style_animation$Animation$lengthUnitName(_p145._1));
};
var _mdgriffith$elm_style_animation$Animation$marginTop = function (_p146) {
	var _p147 = _p146;
	return A3(
		_mdgriffith$elm_style_animation$Animation$length,
		'margin-top',
		_p147._0,
		_mdgriffith$elm_style_animation$Animation$lengthUnitName(_p147._1));
};
var _mdgriffith$elm_style_animation$Animation$marginBottom = function (_p148) {
	var _p149 = _p148;
	return A3(
		_mdgriffith$elm_style_animation$Animation$length,
		'margin-bottom',
		_p149._0,
		_mdgriffith$elm_style_animation$Animation$lengthUnitName(_p149._1));
};
var _mdgriffith$elm_style_animation$Animation$borderWidth = function (_p150) {
	var _p151 = _p150;
	return A3(
		_mdgriffith$elm_style_animation$Animation$length,
		'border-width',
		_p151._0,
		_mdgriffith$elm_style_animation$Animation$lengthUnitName(_p151._1));
};
var _mdgriffith$elm_style_animation$Animation$borderLeftWidth = function (_p152) {
	var _p153 = _p152;
	return A3(
		_mdgriffith$elm_style_animation$Animation$length,
		'border-left-width',
		_p153._0,
		_mdgriffith$elm_style_animation$Animation$lengthUnitName(_p153._1));
};
var _mdgriffith$elm_style_animation$Animation$borderRightWidth = function (_p154) {
	var _p155 = _p154;
	return A3(
		_mdgriffith$elm_style_animation$Animation$length,
		'border-right-width',
		_p155._0,
		_mdgriffith$elm_style_animation$Animation$lengthUnitName(_p155._1));
};
var _mdgriffith$elm_style_animation$Animation$borderTopWidth = function (_p156) {
	var _p157 = _p156;
	return A3(
		_mdgriffith$elm_style_animation$Animation$length,
		'border-top-width',
		_p157._0,
		_mdgriffith$elm_style_animation$Animation$lengthUnitName(_p157._1));
};
var _mdgriffith$elm_style_animation$Animation$borderBottomWidth = function (_p158) {
	var _p159 = _p158;
	return A3(
		_mdgriffith$elm_style_animation$Animation$length,
		'border-bottom-width',
		_p159._0,
		_mdgriffith$elm_style_animation$Animation$lengthUnitName(_p159._1));
};
var _mdgriffith$elm_style_animation$Animation$borderRadius = function (_p160) {
	var _p161 = _p160;
	return A3(
		_mdgriffith$elm_style_animation$Animation$length,
		'border-radius',
		_p161._0,
		_mdgriffith$elm_style_animation$Animation$lengthUnitName(_p161._1));
};
var _mdgriffith$elm_style_animation$Animation$borderTopLeftRadius = function (_p162) {
	var _p163 = _p162;
	return A3(
		_mdgriffith$elm_style_animation$Animation$length,
		'border-top-left-radius',
		_p163._0,
		_mdgriffith$elm_style_animation$Animation$lengthUnitName(_p163._1));
};
var _mdgriffith$elm_style_animation$Animation$borderTopRightRadius = function (_p164) {
	var _p165 = _p164;
	return A3(
		_mdgriffith$elm_style_animation$Animation$length,
		'border-top-right-radius',
		_p165._0,
		_mdgriffith$elm_style_animation$Animation$lengthUnitName(_p165._1));
};
var _mdgriffith$elm_style_animation$Animation$borderBottomLeftRadius = function (_p166) {
	var _p167 = _p166;
	return A3(
		_mdgriffith$elm_style_animation$Animation$length,
		'border-bottom-left-radius',
		_p167._0,
		_mdgriffith$elm_style_animation$Animation$lengthUnitName(_p167._1));
};
var _mdgriffith$elm_style_animation$Animation$borderBottomRightRadius = function (_p168) {
	var _p169 = _p168;
	return A3(
		_mdgriffith$elm_style_animation$Animation$length,
		'border-bottom-right-radius',
		_p169._0,
		_mdgriffith$elm_style_animation$Animation$lengthUnitName(_p169._1));
};
var _mdgriffith$elm_style_animation$Animation$letterSpacing = function (_p170) {
	var _p171 = _p170;
	return A3(
		_mdgriffith$elm_style_animation$Animation$length,
		'letter-spacing',
		_p171._0,
		_mdgriffith$elm_style_animation$Animation$lengthUnitName(_p171._1));
};
var _mdgriffith$elm_style_animation$Animation$lineHeight = function (_p172) {
	var _p173 = _p172;
	return A3(
		_mdgriffith$elm_style_animation$Animation$length,
		'line-height',
		_p173._0,
		_mdgriffith$elm_style_animation$Animation$lengthUnitName(_p173._1));
};
var _mdgriffith$elm_style_animation$Animation$backgroundPosition = F2(
	function (_p175, _p174) {
		var _p176 = _p175;
		var _p177 = _p174;
		return A3(
			_mdgriffith$elm_style_animation$Animation$length2,
			'background-position',
			{
				ctor: '_Tuple2',
				_0: _p176._0,
				_1: _mdgriffith$elm_style_animation$Animation$lengthUnitName(_p176._1)
			},
			{
				ctor: '_Tuple2',
				_0: _p177._0,
				_1: _mdgriffith$elm_style_animation$Animation$lengthUnitName(_p177._1)
			});
	});
var _mdgriffith$elm_style_animation$Animation$translate = F2(
	function (_p179, _p178) {
		var _p180 = _p179;
		var _p181 = _p178;
		return A3(
			_mdgriffith$elm_style_animation$Animation$length2,
			'translate',
			{
				ctor: '_Tuple2',
				_0: _p180._0,
				_1: _mdgriffith$elm_style_animation$Animation$lengthUnitName(_p180._1)
			},
			{
				ctor: '_Tuple2',
				_0: _p181._0,
				_1: _mdgriffith$elm_style_animation$Animation$lengthUnitName(_p181._1)
			});
	});
var _mdgriffith$elm_style_animation$Animation$translate3d = F3(
	function (_p184, _p183, _p182) {
		var _p185 = _p184;
		var _p186 = _p183;
		var _p187 = _p182;
		return A4(
			_mdgriffith$elm_style_animation$Animation$length3,
			'translate3d',
			{
				ctor: '_Tuple2',
				_0: _p185._0,
				_1: _mdgriffith$elm_style_animation$Animation$lengthUnitName(_p185._1)
			},
			{
				ctor: '_Tuple2',
				_0: _p186._0,
				_1: _mdgriffith$elm_style_animation$Animation$lengthUnitName(_p186._1)
			},
			{
				ctor: '_Tuple2',
				_0: _p187._0,
				_1: _mdgriffith$elm_style_animation$Animation$lengthUnitName(_p187._1)
			});
	});
var _mdgriffith$elm_style_animation$Animation$blur = function (_p188) {
	var _p189 = _p188;
	return A3(
		_mdgriffith$elm_style_animation$Animation$length,
		'blur',
		_p189._0,
		_mdgriffith$elm_style_animation$Animation$lengthUnitName(_p189._1));
};
var _mdgriffith$elm_style_animation$Animation$update = F2(
	function (tick, animation) {
		return _elm_lang$core$Tuple$first(
			A2(_mdgriffith$elm_style_animation$Animation_Model$updateAnimation, tick, animation));
	});
var _mdgriffith$elm_style_animation$Animation$debug = function (_p190) {
	var _p191 = _p190;
	var _p201 = _p191._0;
	var time = _p201.timing.current;
	var getValueTuple = function (prop) {
		var _p192 = prop;
		switch (_p192.ctor) {
			case 'ExactProperty':
				return {ctor: '[]'};
			case 'ColorProperty':
				var _p193 = _p192._0;
				return {
					ctor: '::',
					_0: {
						ctor: '_Tuple3',
						_0: A2(_elm_lang$core$Basics_ops['++'], _p193, '-red'),
						_1: _p192._1,
						_2: time
					},
					_1: {
						ctor: '::',
						_0: {
							ctor: '_Tuple3',
							_0: A2(_elm_lang$core$Basics_ops['++'], _p193, '-green'),
							_1: _p192._2,
							_2: time
						},
						_1: {
							ctor: '::',
							_0: {
								ctor: '_Tuple3',
								_0: A2(_elm_lang$core$Basics_ops['++'], _p193, '-blue'),
								_1: _p192._3,
								_2: time
							},
							_1: {
								ctor: '::',
								_0: {
									ctor: '_Tuple3',
									_0: A2(_elm_lang$core$Basics_ops['++'], _p193, '-alpha'),
									_1: _p192._4,
									_2: time
								},
								_1: {ctor: '[]'}
							}
						}
					}
				};
			case 'ShadowProperty':
				var _p195 = _p192._2;
				var _p194 = _p192._0;
				var name = _p192._1 ? A2(_elm_lang$core$Basics_ops['++'], _p194, '-inset') : _p194;
				return {
					ctor: '::',
					_0: {
						ctor: '_Tuple3',
						_0: A2(_elm_lang$core$Basics_ops['++'], name, '-offsetX'),
						_1: _p195.offsetX,
						_2: time
					},
					_1: {
						ctor: '::',
						_0: {
							ctor: '_Tuple3',
							_0: A2(_elm_lang$core$Basics_ops['++'], name, '-offsetY'),
							_1: _p195.offsetY,
							_2: time
						},
						_1: {
							ctor: '::',
							_0: {
								ctor: '_Tuple3',
								_0: A2(_elm_lang$core$Basics_ops['++'], name, '-size'),
								_1: _p195.size,
								_2: time
							},
							_1: {
								ctor: '::',
								_0: {
									ctor: '_Tuple3',
									_0: A2(_elm_lang$core$Basics_ops['++'], name, '-blur'),
									_1: _p195.blur,
									_2: time
								},
								_1: {
									ctor: '::',
									_0: {
										ctor: '_Tuple3',
										_0: A2(_elm_lang$core$Basics_ops['++'], name, '-red'),
										_1: _p195.red,
										_2: time
									},
									_1: {
										ctor: '::',
										_0: {
											ctor: '_Tuple3',
											_0: A2(_elm_lang$core$Basics_ops['++'], name, '-green'),
											_1: _p195.green,
											_2: time
										},
										_1: {
											ctor: '::',
											_0: {
												ctor: '_Tuple3',
												_0: A2(_elm_lang$core$Basics_ops['++'], name, '-blue'),
												_1: _p195.blue,
												_2: time
											},
											_1: {
												ctor: '::',
												_0: {
													ctor: '_Tuple3',
													_0: A2(_elm_lang$core$Basics_ops['++'], name, '-alpha'),
													_1: _p195.alpha,
													_2: time
												},
												_1: {ctor: '[]'}
											}
										}
									}
								}
							}
						}
					}
				};
			case 'Property':
				return {
					ctor: '::',
					_0: {ctor: '_Tuple3', _0: _p192._0, _1: _p192._1, _2: time},
					_1: {ctor: '[]'}
				};
			case 'Property2':
				var _p196 = _p192._0;
				return {
					ctor: '::',
					_0: {
						ctor: '_Tuple3',
						_0: A2(_elm_lang$core$Basics_ops['++'], _p196, '-x'),
						_1: _p192._1,
						_2: time
					},
					_1: {
						ctor: '::',
						_0: {
							ctor: '_Tuple3',
							_0: A2(_elm_lang$core$Basics_ops['++'], _p196, '-y'),
							_1: _p192._2,
							_2: time
						},
						_1: {ctor: '[]'}
					}
				};
			case 'Property3':
				var _p197 = _p192._0;
				return {
					ctor: '::',
					_0: {
						ctor: '_Tuple3',
						_0: A2(_elm_lang$core$Basics_ops['++'], _p197, '-x'),
						_1: _p192._1,
						_2: time
					},
					_1: {
						ctor: '::',
						_0: {
							ctor: '_Tuple3',
							_0: A2(_elm_lang$core$Basics_ops['++'], _p197, '-y'),
							_1: _p192._2,
							_2: time
						},
						_1: {
							ctor: '::',
							_0: {
								ctor: '_Tuple3',
								_0: A2(_elm_lang$core$Basics_ops['++'], _p197, '-z'),
								_1: _p192._3,
								_2: time
							},
							_1: {ctor: '[]'}
						}
					}
				};
			case 'Property4':
				var _p198 = _p192._0;
				return {
					ctor: '::',
					_0: {
						ctor: '_Tuple3',
						_0: A2(_elm_lang$core$Basics_ops['++'], _p198, '-w'),
						_1: _p192._1,
						_2: time
					},
					_1: {
						ctor: '::',
						_0: {
							ctor: '_Tuple3',
							_0: A2(_elm_lang$core$Basics_ops['++'], _p198, '-x'),
							_1: _p192._2,
							_2: time
						},
						_1: {
							ctor: '::',
							_0: {
								ctor: '_Tuple3',
								_0: A2(_elm_lang$core$Basics_ops['++'], _p198, '-y'),
								_1: _p192._3,
								_2: time
							},
							_1: {
								ctor: '::',
								_0: {
									ctor: '_Tuple3',
									_0: A2(_elm_lang$core$Basics_ops['++'], _p198, '-z'),
									_1: _p192._4,
									_2: time
								},
								_1: {ctor: '[]'}
							}
						}
					}
				};
			case 'AngleProperty':
				return {
					ctor: '::',
					_0: {ctor: '_Tuple3', _0: _p192._0, _1: _p192._1, _2: time},
					_1: {ctor: '[]'}
				};
			case 'Points':
				var name = 'points';
				return _elm_lang$core$List$concat(
					A2(
						_elm_lang$core$List$indexedMap,
						F2(
							function (i, _p199) {
								var _p200 = _p199;
								return {
									ctor: '::',
									_0: {
										ctor: '_Tuple3',
										_0: A2(
											_elm_lang$core$Basics_ops['++'],
											_elm_lang$core$Basics$toString(i),
											A2(_elm_lang$core$Basics_ops['++'], name, '-x')),
										_1: _p200._0,
										_2: time
									},
									_1: {
										ctor: '::',
										_0: {
											ctor: '_Tuple3',
											_0: A2(
												_elm_lang$core$Basics_ops['++'],
												_elm_lang$core$Basics$toString(i),
												A2(_elm_lang$core$Basics_ops['++'], name, '-y')),
											_1: _p200._1,
											_2: time
										},
										_1: {ctor: '[]'}
									}
								};
							}),
						_p192._0));
			default:
				return {ctor: '[]'};
		}
	};
	return A2(_elm_lang$core$List$concatMap, getValueTuple, _p201.style);
};
var _mdgriffith$elm_style_animation$Animation$isRunning = function (_p202) {
	var _p203 = _p202;
	return _p203._0.running;
};
var _mdgriffith$elm_style_animation$Animation$subscription = F2(
	function (msg, states) {
		return A2(_elm_lang$core$List$any, _mdgriffith$elm_style_animation$Animation$isRunning, states) ? A2(
			_elm_lang$core$Platform_Sub$map,
			msg,
			_elm_lang$animation_frame$AnimationFrame$times(_mdgriffith$elm_style_animation$Animation_Model$Tick)) : _elm_lang$core$Platform_Sub$none;
	});
var _mdgriffith$elm_style_animation$Animation$extractInitialWait = function (steps) {
	var _p204 = _elm_lang$core$List$head(steps);
	if (_p204.ctor === 'Nothing') {
		return {
			ctor: '_Tuple2',
			_0: 0,
			_1: {ctor: '[]'}
		};
	} else {
		var _p205 = _p204._0;
		if (_p205.ctor === 'Wait') {
			var _p206 = _mdgriffith$elm_style_animation$Animation$extractInitialWait(
				A2(_elm_lang$core$List$drop, 1, steps));
			var additionalTime = _p206._0;
			var remainingSteps = _p206._1;
			return {ctor: '_Tuple2', _0: _p205._0 + additionalTime, _1: remainingSteps};
		} else {
			return {ctor: '_Tuple2', _0: 0, _1: steps};
		}
	}
};
var _mdgriffith$elm_style_animation$Animation$interrupt = F2(
	function (steps, _p207) {
		var _p208 = _p207;
		var _p209 = _p208._0;
		return _mdgriffith$elm_style_animation$Animation_Model$Animation(
			_elm_lang$core$Native_Utils.update(
				_p209,
				{
					interruption: {
						ctor: '::',
						_0: _mdgriffith$elm_style_animation$Animation$extractInitialWait(steps),
						_1: _p209.interruption
					},
					running: true
				}));
	});
var _mdgriffith$elm_style_animation$Animation$queue = F2(
	function (steps, _p210) {
		var _p211 = _p210;
		var _p212 = _p211._0;
		return _mdgriffith$elm_style_animation$Animation_Model$Animation(
			_elm_lang$core$Native_Utils.update(
				_p212,
				{
					steps: A2(_elm_lang$core$Basics_ops['++'], _p212.steps, steps),
					running: true
				}));
	});
var _mdgriffith$elm_style_animation$Animation$warnForDoubleListedProperties = function (props) {
	var _p213 = A2(
		_elm_lang$core$List$map,
		function (propGroup) {
			var _p214 = _elm_lang$core$List$head(propGroup);
			if (_p214.ctor === 'Nothing') {
				return '';
			} else {
				return (_elm_lang$core$Native_Utils.cmp(
					_elm_lang$core$List$length(propGroup),
					1) > 0) ? A2(
					_elm_lang$core$Debug$log,
					'elm-style-animation',
					A2(
						_elm_lang$core$Basics_ops['++'],
						'The \"',
						A2(_elm_lang$core$Basics_ops['++'], _p214._0, '\" css property is listed more than once.  Only the last instance will be used.'))) : '';
			}
		},
		A2(
			_elm_community$list_extra$List_Extra$groupWhile,
			F2(
				function (x, y) {
					return _elm_lang$core$Native_Utils.eq(x, y);
				}),
			_elm_lang$core$List$sort(
				A2(
					_elm_lang$core$List$map,
					_mdgriffith$elm_style_animation$Animation_Model$propertyName,
					A2(
						_elm_lang$core$List$filter,
						function (prop) {
							return !_mdgriffith$elm_style_animation$Animation$isTransformation(prop);
						},
						props)))));
	return props;
};
var _mdgriffith$elm_style_animation$Animation$initialState = function (current) {
	return _mdgriffith$elm_style_animation$Animation_Model$Animation(
		{
			steps: {ctor: '[]'},
			style: current,
			timing: {current: 0, dt: 0},
			running: false,
			interruption: {ctor: '[]'}
		});
};
var _mdgriffith$elm_style_animation$Animation$styleWith = F2(
	function (interp, props) {
		return _mdgriffith$elm_style_animation$Animation$initialState(
			A2(
				_elm_lang$core$List$map,
				_mdgriffith$elm_style_animation$Animation_Model$mapToMotion(
					function (m) {
						return _elm_lang$core$Native_Utils.update(
							m,
							{interpolation: interp});
					}),
				_mdgriffith$elm_style_animation$Animation$warnForDoubleListedProperties(props)));
	});
var _mdgriffith$elm_style_animation$Animation$styleWithEach = function (props) {
	var _p215 = _mdgriffith$elm_style_animation$Animation$warnForDoubleListedProperties(
		A2(_elm_lang$core$List$map, _elm_lang$core$Tuple$second, props));
	return _mdgriffith$elm_style_animation$Animation$initialState(
		A2(
			_elm_lang$core$List$map,
			function (_p216) {
				var _p217 = _p216;
				return A2(
					_mdgriffith$elm_style_animation$Animation_Model$mapToMotion,
					function (m) {
						return _elm_lang$core$Native_Utils.update(
							m,
							{interpolation: _p217._0});
					},
					_p217._1);
			},
			props));
};
var _mdgriffith$elm_style_animation$Animation$loop = function (steps) {
	return _mdgriffith$elm_style_animation$Animation_Model$Loop(steps);
};
var _mdgriffith$elm_style_animation$Animation$repeat = F2(
	function (n, steps) {
		return A2(_mdgriffith$elm_style_animation$Animation_Model$Repeat, n, steps);
	});
var _mdgriffith$elm_style_animation$Animation$set = function (props) {
	return _mdgriffith$elm_style_animation$Animation_Model$Set(props);
};
var _mdgriffith$elm_style_animation$Animation$toWithEach = function (interpProps) {
	return _mdgriffith$elm_style_animation$Animation_Model$ToWith(
		A2(
			_elm_lang$core$List$map,
			function (_p218) {
				var _p219 = _p218;
				return A2(
					_mdgriffith$elm_style_animation$Animation_Model$mapToMotion,
					function (m) {
						return _elm_lang$core$Native_Utils.update(
							m,
							{interpolation: _p219._0});
					},
					_p219._1);
			},
			interpProps));
};
var _mdgriffith$elm_style_animation$Animation$toWith = F2(
	function (interp, props) {
		return _mdgriffith$elm_style_animation$Animation_Model$ToWith(
			A2(
				_elm_lang$core$List$map,
				_mdgriffith$elm_style_animation$Animation_Model$mapToMotion(
					function (m) {
						return _elm_lang$core$Native_Utils.update(
							m,
							{interpolation: interp});
					}),
				props));
	});
var _mdgriffith$elm_style_animation$Animation$to = function (props) {
	return _mdgriffith$elm_style_animation$Animation_Model$To(props);
};
var _mdgriffith$elm_style_animation$Animation$wait = function (till) {
	return _mdgriffith$elm_style_animation$Animation_Model$Wait(till);
};
var _mdgriffith$elm_style_animation$Animation$speed = function (speed) {
	return _mdgriffith$elm_style_animation$Animation_Model$AtSpeed(speed);
};
var _mdgriffith$elm_style_animation$Animation$defaultInterpolationByProperty = function (prop) {
	var linear = function (duration) {
		return _mdgriffith$elm_style_animation$Animation_Model$Easing(
			{progress: 1, start: 0, duration: duration, ease: _elm_lang$core$Basics$identity});
	};
	var spring = _mdgriffith$elm_style_animation$Animation_Model$Spring(
		{stiffness: 170, damping: 26});
	var _p220 = prop;
	switch (_p220.ctor) {
		case 'ExactProperty':
			return spring;
		case 'ColorProperty':
			return linear(0.4 * _elm_lang$core$Time$second);
		case 'ShadowProperty':
			return spring;
		case 'Property':
			return spring;
		case 'Property2':
			return spring;
		case 'Property3':
			return _elm_lang$core$Native_Utils.eq(_p220._0, 'rotate3d') ? _mdgriffith$elm_style_animation$Animation$speed(
				{perSecond: _elm_lang$core$Basics$pi}) : spring;
		case 'Property4':
			return spring;
		case 'AngleProperty':
			return _mdgriffith$elm_style_animation$Animation$speed(
				{perSecond: _elm_lang$core$Basics$pi});
		case 'Points':
			return spring;
		default:
			return spring;
	}
};
var _mdgriffith$elm_style_animation$Animation$setDefaultInterpolation = function (prop) {
	var interp = _mdgriffith$elm_style_animation$Animation$defaultInterpolationByProperty(prop);
	return A2(
		_mdgriffith$elm_style_animation$Animation_Model$mapToMotion,
		function (m) {
			return _elm_lang$core$Native_Utils.update(
				m,
				{interpolation: interp});
		},
		prop);
};
var _mdgriffith$elm_style_animation$Animation$style = function (props) {
	return _mdgriffith$elm_style_animation$Animation$initialState(
		A2(
			_elm_lang$core$List$map,
			_mdgriffith$elm_style_animation$Animation$setDefaultInterpolation,
			_mdgriffith$elm_style_animation$Animation$warnForDoubleListedProperties(props)));
};
var _mdgriffith$elm_style_animation$Animation$easing = function (_p221) {
	var _p222 = _p221;
	return _mdgriffith$elm_style_animation$Animation_Model$Easing(
		{progress: 1, duration: _p222.duration, start: 0, ease: _p222.ease});
};
var _mdgriffith$elm_style_animation$Animation$spring = function (settings) {
	return _mdgriffith$elm_style_animation$Animation_Model$Spring(settings);
};
var _mdgriffith$elm_style_animation$Animation$Shadow = F5(
	function (a, b, c, d, e) {
		return {offsetX: a, offsetY: b, size: c, blur: d, color: e};
	});
var _mdgriffith$elm_style_animation$Animation$CubicCurve = F3(
	function (a, b, c) {
		return {control1: a, control2: b, point: c};
	});
var _mdgriffith$elm_style_animation$Animation$QuadraticCurve = F2(
	function (a, b) {
		return {control: a, point: b};
	});
var _mdgriffith$elm_style_animation$Animation$Arc = F6(
	function (a, b, c, d, e, f) {
		return {x: a, y: b, radius: c, startAngle: d, endAngle: e, clockwise: f};
	});
var _mdgriffith$elm_style_animation$Animation$Pc = {ctor: 'Pc'};
var _mdgriffith$elm_style_animation$Animation$Pt = {ctor: 'Pt'};
var _mdgriffith$elm_style_animation$Animation$In = {ctor: 'In'};
var _mdgriffith$elm_style_animation$Animation$Cm = {ctor: 'Cm'};
var _mdgriffith$elm_style_animation$Animation$Mm = {ctor: 'Mm'};
var _mdgriffith$elm_style_animation$Animation$Vmax = {ctor: 'Vmax'};
var _mdgriffith$elm_style_animation$Animation$Vmin = {ctor: 'Vmin'};
var _mdgriffith$elm_style_animation$Animation$Vw = {ctor: 'Vw'};
var _mdgriffith$elm_style_animation$Animation$Vh = {ctor: 'Vh'};
var _mdgriffith$elm_style_animation$Animation$Ch = {ctor: 'Ch'};
var _mdgriffith$elm_style_animation$Animation$Ex = {ctor: 'Ex'};
var _mdgriffith$elm_style_animation$Animation$Em = {ctor: 'Em'};
var _mdgriffith$elm_style_animation$Animation$Rem = {ctor: 'Rem'};
var _mdgriffith$elm_style_animation$Animation$Percent = {ctor: 'Percent'};
var _mdgriffith$elm_style_animation$Animation$Px = {ctor: 'Px'};
var _mdgriffith$elm_style_animation$Animation$NoUnit = {ctor: 'NoUnit'};
var _mdgriffith$elm_style_animation$Animation$Length = F2(
	function (a, b) {
		return {ctor: 'Length', _0: a, _1: b};
	});
var _mdgriffith$elm_style_animation$Animation$px = function (x) {
	return A2(_mdgriffith$elm_style_animation$Animation$Length, x, _mdgriffith$elm_style_animation$Animation$Px);
};
var _mdgriffith$elm_style_animation$Animation$percent = function (x) {
	return A2(_mdgriffith$elm_style_animation$Animation$Length, x, _mdgriffith$elm_style_animation$Animation$Percent);
};
var _mdgriffith$elm_style_animation$Animation$rem = function (x) {
	return A2(_mdgriffith$elm_style_animation$Animation$Length, x, _mdgriffith$elm_style_animation$Animation$Rem);
};
var _mdgriffith$elm_style_animation$Animation$em = function (x) {
	return A2(_mdgriffith$elm_style_animation$Animation$Length, x, _mdgriffith$elm_style_animation$Animation$Em);
};
var _mdgriffith$elm_style_animation$Animation$ex = function (x) {
	return A2(_mdgriffith$elm_style_animation$Animation$Length, x, _mdgriffith$elm_style_animation$Animation$Ex);
};
var _mdgriffith$elm_style_animation$Animation$ch = function (x) {
	return A2(_mdgriffith$elm_style_animation$Animation$Length, x, _mdgriffith$elm_style_animation$Animation$Ch);
};
var _mdgriffith$elm_style_animation$Animation$vh = function (x) {
	return A2(_mdgriffith$elm_style_animation$Animation$Length, x, _mdgriffith$elm_style_animation$Animation$Vh);
};
var _mdgriffith$elm_style_animation$Animation$vw = function (x) {
	return A2(_mdgriffith$elm_style_animation$Animation$Length, x, _mdgriffith$elm_style_animation$Animation$Vw);
};
var _mdgriffith$elm_style_animation$Animation$vmin = function (x) {
	return A2(_mdgriffith$elm_style_animation$Animation$Length, x, _mdgriffith$elm_style_animation$Animation$Vmin);
};
var _mdgriffith$elm_style_animation$Animation$vmax = function (x) {
	return A2(_mdgriffith$elm_style_animation$Animation$Length, x, _mdgriffith$elm_style_animation$Animation$Vmax);
};
var _mdgriffith$elm_style_animation$Animation$mm = function (x) {
	return A2(_mdgriffith$elm_style_animation$Animation$Length, x, _mdgriffith$elm_style_animation$Animation$Mm);
};
var _mdgriffith$elm_style_animation$Animation$cm = function (x) {
	return A2(_mdgriffith$elm_style_animation$Animation$Length, x, _mdgriffith$elm_style_animation$Animation$Cm);
};
var _mdgriffith$elm_style_animation$Animation$inches = function (x) {
	return A2(_mdgriffith$elm_style_animation$Animation$Length, x, _mdgriffith$elm_style_animation$Animation$In);
};
var _mdgriffith$elm_style_animation$Animation$pt = function (x) {
	return A2(_mdgriffith$elm_style_animation$Animation$Length, x, _mdgriffith$elm_style_animation$Animation$Pt);
};
var _mdgriffith$elm_style_animation$Animation$pc = function (x) {
	return A2(_mdgriffith$elm_style_animation$Animation$Length, x, _mdgriffith$elm_style_animation$Animation$Pc);
};
var _mdgriffith$elm_style_animation$Animation$Radians = function (a) {
	return {ctor: 'Radians', _0: a};
};
var _mdgriffith$elm_style_animation$Animation$deg = function (a) {
	return _mdgriffith$elm_style_animation$Animation$Radians((a / 360) * (2 * _elm_lang$core$Basics$pi));
};
var _mdgriffith$elm_style_animation$Animation$grad = function (a) {
	return _mdgriffith$elm_style_animation$Animation$Radians((a / 400) * (2 * _elm_lang$core$Basics$pi));
};
var _mdgriffith$elm_style_animation$Animation$rad = function (a) {
	return _mdgriffith$elm_style_animation$Animation$Radians(a);
};
var _mdgriffith$elm_style_animation$Animation$turn = function (a) {
	return _mdgriffith$elm_style_animation$Animation$Radians(a * (2 * _elm_lang$core$Basics$pi));
};
var _mdgriffith$elm_style_animation$Animation$ListItem = {ctor: 'ListItem'};
var _mdgriffith$elm_style_animation$Animation$listItem = _mdgriffith$elm_style_animation$Animation$ListItem;
var _mdgriffith$elm_style_animation$Animation$InlineFlex = {ctor: 'InlineFlex'};
var _mdgriffith$elm_style_animation$Animation$inlineFlex = _mdgriffith$elm_style_animation$Animation$InlineFlex;
var _mdgriffith$elm_style_animation$Animation$Flex = {ctor: 'Flex'};
var _mdgriffith$elm_style_animation$Animation$flex = _mdgriffith$elm_style_animation$Animation$Flex;
var _mdgriffith$elm_style_animation$Animation$Block = {ctor: 'Block'};
var _mdgriffith$elm_style_animation$Animation$block = _mdgriffith$elm_style_animation$Animation$Block;
var _mdgriffith$elm_style_animation$Animation$InlineBlock = {ctor: 'InlineBlock'};
var _mdgriffith$elm_style_animation$Animation$inlineBlock = _mdgriffith$elm_style_animation$Animation$InlineBlock;
var _mdgriffith$elm_style_animation$Animation$Inline = {ctor: 'Inline'};
var _mdgriffith$elm_style_animation$Animation$inline = _mdgriffith$elm_style_animation$Animation$Inline;
var _mdgriffith$elm_style_animation$Animation$None = {ctor: 'None'};
var _mdgriffith$elm_style_animation$Animation$none = _mdgriffith$elm_style_animation$Animation$None;

var _mdgriffith$elm_style_animation$Animation_Messenger$send = function (msg) {
	return _mdgriffith$elm_style_animation$Animation_Model$Send(msg);
};
var _mdgriffith$elm_style_animation$Animation_Messenger$update = F2(
	function (tick, animation) {
		return A2(_mdgriffith$elm_style_animation$Animation_Model$updateAnimation, tick, animation);
	});

var _user$project$Animals_Pages_Declare$helpPagePath = '/v2/animals/help';
var _user$project$Animals_Pages_Declare$addPagePath = '/v2/animals/new';
var _user$project$Animals_Pages_Declare$allPagePath = '/v2/animals';
var _user$project$Animals_Pages_Declare$HelpPage = {ctor: 'HelpPage'};
var _user$project$Animals_Pages_Declare$AddPage = {ctor: 'AddPage'};
var _user$project$Animals_Pages_Declare$AllPage = {ctor: 'AllPage'};

var _user$project$Pile_HtmlShorthand$onEnter = function (msg) {
	var isEnter = function (code) {
		return _elm_lang$core$Native_Utils.eq(code, 13) ? _elm_lang$core$Json_Decode$succeed(msg) : _elm_lang$core$Json_Decode$fail('not ENTER');
	};
	return A2(
		_elm_lang$html$Html_Events$on,
		'keydown',
		A2(_elm_lang$core$Json_Decode$andThen, isEnter, _elm_lang$html$Html_Events$keyCode));
};
var _user$project$Pile_HtmlShorthand$onClickWithoutPropagation = function (msg) {
	return A3(
		_elm_lang$html$Html_Events$onWithOptions,
		'click',
		{stopPropagation: false, preventDefault: true},
		_elm_lang$core$Json_Decode$succeed(msg));
};

var _user$project$Pile_Bulma$deleteButton = function (msg) {
	return A2(
		_elm_lang$html$Html$button,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('delete'),
			_1: {
				ctor: '::',
				_0: _elm_lang$html$Html_Events$onClick(msg),
				_1: {ctor: '[]'}
			}
		},
		{ctor: '[]'});
};
var _user$project$Pile_Bulma$flashNotification = F2(
	function (msg, contentList) {
		return A2(
			_elm_lang$html$Html$div,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class('notification is-warning'),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: _user$project$Pile_Bulma$deleteButton(msg),
				_1: contentList
			});
	});
var _user$project$Pile_Bulma$rightwardCancel = function (msg) {
	return A2(
		_elm_lang$html$Html$p,
		{ctor: '[]'},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$a,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('button is-danger pull-right'),
					_1: {
						ctor: '::',
						_0: _user$project$Pile_HtmlShorthand$onClickWithoutPropagation(msg),
						_1: {ctor: '[]'}
					}
				},
				{
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$span,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class('icon'),
							_1: {ctor: '[]'}
						},
						{
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$i,
								{
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$class('fa fa-times'),
									_1: {ctor: '[]'}
								},
								{ctor: '[]'}),
							_1: {ctor: '[]'}
						}),
					_1: {
						ctor: '::',
						_0: _elm_lang$html$Html$text('Cancel'),
						_1: {ctor: '[]'}
					}
				}),
			_1: {ctor: '[]'}
		});
};
var _user$project$Pile_Bulma$leftwardSave = F2(
	function (enabled, msg) {
		var attributes = function () {
			var _p0 = enabled;
			if (_p0 === true) {
				return {
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('button is-success pull-left'),
					_1: {
						ctor: '::',
						_0: _user$project$Pile_HtmlShorthand$onClickWithoutPropagation(msg),
						_1: {ctor: '[]'}
					}
				};
			} else {
				return {
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('button is-success pull-left is-disabled'),
					_1: {ctor: '[]'}
				};
			}
		}();
		return A2(
			_elm_lang$html$Html$p,
			{ctor: '[]'},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$a,
					attributes,
					{
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$span,
							{
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$class('icon'),
								_1: {ctor: '[]'}
							},
							{
								ctor: '::',
								_0: A2(
									_elm_lang$html$Html$i,
									{
										ctor: '::',
										_0: _elm_lang$html$Html_Attributes$class('fa fa-check'),
										_1: {ctor: '[]'}
									},
									{ctor: '[]'}),
								_1: {ctor: '[]'}
							}),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html$text('Save'),
							_1: {ctor: '[]'}
						}
					}),
				_1: {ctor: '[]'}
			});
	});
var _user$project$Pile_Bulma$exampleSuccess = A2(
	_elm_lang$html$Html$a,
	{
		ctor: '::',
		_0: _elm_lang$html$Html_Attributes$class('button is-success is-small'),
		_1: {ctor: '[]'}
	},
	{
		ctor: '::',
		_0: A2(
			_elm_lang$html$Html$span,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class('icon'),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$i,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('fa fa-check'),
						_1: {ctor: '[]'}
					},
					{ctor: '[]'}),
				_1: {ctor: '[]'}
			}),
		_1: {
			ctor: '::',
			_0: _elm_lang$html$Html$text('Save'),
			_1: {ctor: '[]'}
		}
	});
var _user$project$Pile_Bulma$oneTextInputInRow = function (extraAttributes) {
	return A2(
		_elm_lang$html$Html$p,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('control'),
			_1: {ctor: '[]'}
		},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$input,
				A2(
					_elm_lang$core$Basics_ops['++'],
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('input'),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$type_('text'),
							_1: {ctor: '[]'}
						}
					},
					extraAttributes),
				{ctor: '[]'}),
			_1: {ctor: '[]'}
		});
};
var _user$project$Pile_Bulma$textInputWithSubmit = F4(
	function (buttonLabel, fieldValue, inputMsg, submitMsg) {
		return A2(
			_elm_lang$html$Html$div,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class('control has-addons'),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: _user$project$Pile_Bulma$oneTextInputInRow(
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$value(fieldValue),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html_Events$onInput(inputMsg),
							_1: {
								ctor: '::',
								_0: _user$project$Pile_HtmlShorthand$onEnter(submitMsg),
								_1: {ctor: '[]'}
							}
						}
					}),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$a,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class('button is-success'),
							_1: {
								ctor: '::',
								_0: _user$project$Pile_HtmlShorthand$onClickWithoutPropagation(submitMsg),
								_1: {ctor: '[]'}
							}
						},
						{
							ctor: '::',
							_0: _elm_lang$html$Html$text(buttonLabel),
							_1: {ctor: '[]'}
						}),
					_1: {ctor: '[]'}
				}
			});
	});
var _user$project$Pile_Bulma$horizontalControls = function (controls) {
	return A2(
		_elm_lang$html$Html$div,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('control is-grouped'),
			_1: {ctor: '[]'}
		},
		controls);
};
var _user$project$Pile_Bulma$oneReasonablySizedControl = function (control) {
	return A2(
		_elm_lang$html$Html$div,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('control is-grouped'),
			_1: {ctor: '[]'}
		},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$p,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('control'),
					_1: {ctor: '[]'}
				},
				{
					ctor: '::',
					_0: control,
					_1: {ctor: '[]'}
				}),
			_1: {ctor: '[]'}
		});
};
var _user$project$Pile_Bulma$soleTextInputInRow = F2(
	function (fieldValue, extraAttributes) {
		var _p1 = function () {
			var _p2 = fieldValue.validity;
			if (_p2.ctor === 'Valid') {
				return {
					ctor: '_Tuple3',
					_0: 'control',
					_1: 'input',
					_2: {ctor: '[]'}
				};
			} else {
				return {
					ctor: '_Tuple3',
					_0: 'control has-icon has-icon-right',
					_1: 'input is-danger',
					_2: {
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$i,
							{
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$class('fa fa-warning'),
								_1: {ctor: '[]'}
							},
							{ctor: '[]'}),
						_1: {ctor: '[]'}
					}
				};
			}
		}();
		var paragraphClasses = _p1._0;
		var fieldClasses = _p1._1;
		var fieldIcons = _p1._2;
		var oneCommentary = function (_p3) {
			var _p4 = _p3;
			return A2(
				_elm_lang$html$Html$span,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('help is-danger'),
					_1: {ctor: '[]'}
				},
				{
					ctor: '::',
					_0: _elm_lang$html$Html$text(_p4._1),
					_1: {ctor: '[]'}
				});
		};
		var field = A2(
			_elm_lang$html$Html$input,
			A2(
				_elm_lang$core$Basics_ops['++'],
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class(fieldClasses),
					_1: {
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$type_('text'),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$value(fieldValue.value),
							_1: {ctor: '[]'}
						}
					}
				},
				extraAttributes),
			{ctor: '[]'});
		var contents = A2(
			_elm_lang$core$Basics_ops['++'],
			{
				ctor: '::',
				_0: field,
				_1: {ctor: '[]'}
			},
			A2(
				_elm_lang$core$Basics_ops['++'],
				fieldIcons,
				A2(_elm_lang$core$List$map, oneCommentary, fieldValue.commentary)));
		return _user$project$Pile_Bulma$oneReasonablySizedControl(
			A2(
				_elm_lang$html$Html$p,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class(paragraphClasses),
					_1: {ctor: '[]'}
				},
				contents));
	});
var _user$project$Pile_Bulma$controlRow = F2(
	function (labelText, controlPart) {
		return A2(
			_elm_lang$html$Html$div,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class('control is-horizontal'),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$div,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('control-label'),
						_1: {ctor: '[]'}
					},
					{
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$label,
							{
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$class('label'),
								_1: {ctor: '[]'}
							},
							{
								ctor: '::',
								_0: _elm_lang$html$Html$text(labelText),
								_1: {ctor: '[]'}
							}),
						_1: {ctor: '[]'}
					}),
				_1: {
					ctor: '::',
					_0: controlPart,
					_1: {ctor: '[]'}
				}
			});
	});
var _user$project$Pile_Bulma$distributeHorizontally = function (contents) {
	return A2(
		_elm_lang$html$Html$div,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('level'),
			_1: {ctor: '[]'}
		},
		contents);
};
var _user$project$Pile_Bulma$highlightedRow = F2(
	function (attributes, cells) {
		var emphasis = _elm_lang$html$Html_Attributes$style(
			{
				ctor: '::',
				_0: {ctor: '_Tuple2', _0: 'border-top', _1: '2px solid'},
				_1: {
					ctor: '::',
					_0: {ctor: '_Tuple2', _0: 'border-bottom', _1: '2px solid'},
					_1: {ctor: '[]'}
				}
			});
		return A2(
			_elm_lang$html$Html$tr,
			{ctor: '::', _0: emphasis, _1: attributes},
			cells);
	});
var _user$project$Pile_Bulma$propertyTable = function (body) {
	return A2(
		_elm_lang$html$Html$table,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$style(
				{
					ctor: '::',
					_0: {ctor: '_Tuple2', _0: 'width', _1: 'auto'},
					_1: {ctor: '[]'}
				}),
			_1: {
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class('table is-bordered'),
				_1: {ctor: '[]'}
			}
		},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$tbody,
				{ctor: '[]'},
				body),
			_1: {ctor: '[]'}
		});
};
var _user$project$Pile_Bulma$headerlessTable = function (body) {
	return A2(
		_elm_lang$html$Html$table,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('table'),
			_1: {ctor: '[]'}
		},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$tbody,
				{ctor: '[]'},
				body),
			_1: {ctor: '[]'}
		});
};
var _user$project$Pile_Bulma$column = F2(
	function (n, contents) {
		return A2(
			_elm_lang$html$Html$div,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class(
					A2(
						_elm_lang$core$Basics_ops['++'],
						'column is-',
						_elm_lang$core$Basics$toString(n))),
				_1: {ctor: '[]'}
			},
			contents);
	});
var _user$project$Pile_Bulma$centeredColumns = function (contents) {
	return A2(
		_elm_lang$html$Html$div,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('columns is-centered'),
			_1: {ctor: '[]'}
		},
		contents);
};
var _user$project$Pile_Bulma$simpleTextInput = F2(
	function (val, msg) {
		return A2(
			_elm_lang$html$Html$p,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class('control'),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$input,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('input'),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$type_('text'),
							_1: {
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$value(val),
								_1: {
									ctor: '::',
									_0: _elm_lang$html$Html_Events$onInput(msg),
									_1: {ctor: '[]'}
								}
							}
						}
					},
					{ctor: '[]'}),
				_1: {ctor: '[]'}
			});
	});
var _user$project$Pile_Bulma$headingP = function (heading) {
	return A2(
		_elm_lang$html$Html$p,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('heading'),
			_1: {ctor: '[]'}
		},
		{
			ctor: '::',
			_0: _elm_lang$html$Html$text(heading),
			_1: {ctor: '[]'}
		});
};
var _user$project$Pile_Bulma$disabledSelect = function (content) {
	return A2(
		_elm_lang$html$Html$span,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('select'),
			_1: {ctor: '[]'}
		},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$select,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$disabled(true),
					_1: {ctor: '[]'}
				},
				content),
			_1: {ctor: '[]'}
		});
};
var _user$project$Pile_Bulma$simpleSelect = function (content) {
	return A2(
		_elm_lang$html$Html$span,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('select'),
			_1: {ctor: '[]'}
		},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$select,
				{ctor: '[]'},
				content),
			_1: {ctor: '[]'}
		});
};
var _user$project$Pile_Bulma$centeredLevelItem = function (content) {
	return A2(
		_elm_lang$html$Html$div,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('level-item has-text-centered'),
			_1: {ctor: '[]'}
		},
		content);
};
var _user$project$Pile_Bulma$messageView = F2(
	function (headerList, contentList) {
		return A2(
			_elm_lang$html$Html$article,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class('message'),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$div,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('message-header has-text-centered'),
						_1: {ctor: '[]'}
					},
					headerList),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$div,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class('message-body'),
							_1: {ctor: '[]'}
						},
						contentList),
					_1: {ctor: '[]'}
				}
			});
	});
var _user$project$Pile_Bulma$deletableTag = F2(
	function (msg, tagText) {
		return A2(
			_elm_lang$html$Html$p,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class('tag is-primary control'),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: _elm_lang$html$Html$text(tagText),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$button,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class('delete'),
							_1: {
								ctor: '::',
								_0: _elm_lang$html$Html_Events$onClick(
									msg(tagText)),
								_1: {ctor: '[]'}
							}
						},
						{ctor: '[]'}),
					_1: {ctor: '[]'}
				}
			});
	});
var _user$project$Pile_Bulma$readOnlyTag = function (tagText) {
	return A2(
		_elm_lang$html$Html$span,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('tag'),
			_1: {ctor: '[]'}
		},
		{
			ctor: '::',
			_0: _elm_lang$html$Html$text(tagText),
			_1: {ctor: '[]'}
		});
};
var _user$project$Pile_Bulma$coloredIcon = F2(
	function (iconName, color) {
		return A2(
			_elm_lang$html$Html$i,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class(
					A2(_elm_lang$core$Basics_ops['++'], 'fa ', iconName)),
				_1: {
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$style(
						{
							ctor: '::',
							_0: {ctor: '_Tuple2', _0: 'color', _1: color},
							_1: {ctor: '[]'}
						}),
					_1: {ctor: '[]'}
				}
			},
			{ctor: '[]'});
	});
var _user$project$Pile_Bulma$trueIcon = A2(_user$project$Pile_Bulma$coloredIcon, 'fa-check', 'green');
var _user$project$Pile_Bulma$falseIcon = A2(_user$project$Pile_Bulma$coloredIcon, 'fa-times', 'red');
var _user$project$Pile_Bulma$rightIcon = F3(
	function (iconSymbolName, tooltip, msg) {
		return A2(
			_elm_lang$html$Html$a,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$href('#'),
				_1: {
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('icon is-pulled-right'),
					_1: {
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$title(tooltip),
						_1: {
							ctor: '::',
							_0: _user$project$Pile_HtmlShorthand$onClickWithoutPropagation(msg),
							_1: {ctor: '[]'}
						}
					}
				}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$i,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class(
							A2(_elm_lang$core$Basics_ops['++'], 'fa ', iconSymbolName)),
						_1: {ctor: '[]'}
					},
					{ctor: '[]'}),
				_1: {ctor: '[]'}
			});
	});
var _user$project$Pile_Bulma$plainIcon = F3(
	function (iconSymbolName, tooltip, msg) {
		return A2(
			_elm_lang$html$Html$a,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$href('#'),
				_1: {
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('icon'),
					_1: {
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$title(tooltip),
						_1: {
							ctor: '::',
							_0: _user$project$Pile_HtmlShorthand$onClickWithoutPropagation(msg),
							_1: {ctor: '[]'}
						}
					}
				}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$i,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class(
							A2(_elm_lang$core$Basics_ops['++'], 'fa ', iconSymbolName)),
						_1: {ctor: '[]'}
					},
					{ctor: '[]'}),
				_1: {ctor: '[]'}
			});
	});
var _user$project$Pile_Bulma$tdIcon = F3(
	function (iconSymbolName, tooltip, msg) {
		return A2(
			_elm_lang$html$Html$td,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class('is-icon'),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$a,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$href('#'),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$title(tooltip),
							_1: {
								ctor: '::',
								_0: _user$project$Pile_HtmlShorthand$onClickWithoutPropagation(msg),
								_1: {ctor: '[]'}
							}
						}
					},
					{
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$i,
							{
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$class(
									A2(_elm_lang$core$Basics_ops['++'], 'fa ', iconSymbolName)),
								_1: {ctor: '[]'}
							},
							{ctor: '[]'}),
						_1: {ctor: '[]'}
					}),
				_1: {ctor: '[]'}
			});
	});
var _user$project$Pile_Bulma$shortenWidth = function (content) {
	return A2(
		_elm_lang$html$Html$div,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('columns is-centered is-mobile'),
			_1: {ctor: '[]'}
		},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$div,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('column is-10 has-text-centered'),
					_1: {ctor: '[]'}
				},
				content),
			_1: {ctor: '[]'}
		});
};
var _user$project$Pile_Bulma$message = F3(
	function (kind, header, body) {
		return _user$project$Pile_Bulma$shortenWidth(
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$article,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class(
							A2(_elm_lang$core$Basics_ops['++'], 'message ', kind)),
						_1: {ctor: '[]'}
					},
					{
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$div,
							{
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$class('message-header'),
								_1: {ctor: '[]'}
							},
							{
								ctor: '::',
								_0: _elm_lang$html$Html$text(header),
								_1: {ctor: '[]'}
							}),
						_1: {
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$div,
								{
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$class('message-body'),
									_1: {ctor: '[]'}
								},
								{
									ctor: '::',
									_0: _elm_lang$html$Html$text(body),
									_1: {ctor: '[]'}
								}),
							_1: {ctor: '[]'}
						}
					}),
				_1: {ctor: '[]'}
			});
	});
var _user$project$Pile_Bulma$infoMessage = _user$project$Pile_Bulma$message('is-info');
var _user$project$Pile_Bulma$tab = F2(
	function (selectedPage, _p5) {
		var _p6 = _p5;
		var _p7 = _elm_lang$core$Native_Utils.eq(selectedPage, _p6._0) ? {
			ctor: '_Tuple4',
			_0: 'is-active',
			_1: 'is-disabled',
			_2: {
				ctor: '::',
				_0: {ctor: '_Tuple2', _0: 'background-color', _1: '#4a4a4a'},
				_1: {
					ctor: '::',
					_0: {ctor: '_Tuple2', _0: 'border-width', _1: '1'},
					_1: {
						ctor: '::',
						_0: {ctor: '_Tuple2', _0: 'border-color', _1: '#4a4a4a'},
						_1: {
							ctor: '::',
							_0: {ctor: '_Tuple2', _0: 'border-radius', _1: '0px'},
							_1: {ctor: '[]'}
						}
					}
				}
			},
			_3: 'is-info'
		} : {
			ctor: '_Tuple4',
			_0: '',
			_1: '',
			_2: {ctor: '[]'},
			_3: ''
		};
		var liClass = _p7._0;
		var linkClass = _p7._1;
		var linkStyle = _p7._2;
		var spanClass = _p7._3;
		return A2(
			_elm_lang$html$Html$li,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class(liClass),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$a,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class(linkClass),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$style(linkStyle),
							_1: {
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$href('#'),
								_1: {
									ctor: '::',
									_0: _user$project$Pile_HtmlShorthand$onClickWithoutPropagation(_p6._2),
									_1: {ctor: '[]'}
								}
							}
						}
					},
					{
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$span,
							{
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$class(spanClass),
								_1: {ctor: '[]'}
							},
							{
								ctor: '::',
								_0: _elm_lang$html$Html$text(_p6._1),
								_1: {ctor: '[]'}
							}),
						_1: {ctor: '[]'}
					}),
				_1: {ctor: '[]'}
			});
	});
var _user$project$Pile_Bulma$tabs = F2(
	function (selectedPage, tabList) {
		return A2(
			_elm_lang$html$Html$div,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class('tabs is-centered is-toggle'),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$ul,
					{ctor: '[]'},
					A2(
						_elm_lang$core$List$map,
						_user$project$Pile_Bulma$tab(selectedPage),
						tabList)),
				_1: {ctor: '[]'}
			});
	});
var _user$project$Pile_Bulma$FormValue = F3(
	function (a, b, c) {
		return {validity: a, value: b, commentary: c};
	});
var _user$project$Pile_Bulma$Error = {ctor: 'Error'};
var _user$project$Pile_Bulma$Info = {ctor: 'Info'};
var _user$project$Pile_Bulma$Invalid = {ctor: 'Invalid'};
var _user$project$Pile_Bulma$Valid = {ctor: 'Valid'};

var _user$project$Animals_Animal_Flash$showWithButton = F2(
	function (flash, msg) {
		var _p0 = flash;
		if (_p0.ctor === 'NoFlash') {
			return A2(
				_elm_lang$html$Html$span,
				{ctor: '[]'},
				{ctor: '[]'});
		} else {
			return A2(
				_user$project$Pile_Bulma$flashNotification,
				msg,
				{
					ctor: '::',
					_0: _elm_lang$html$Html$text('Excuse me for butting in, but I notice you clicked '),
					_1: {
						ctor: '::',
						_0: _user$project$Pile_Bulma$exampleSuccess,
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html$text(' while there was text in the '),
							_1: {
								ctor: '::',
								_0: A2(
									_elm_lang$html$Html$b,
									{ctor: '[]'},
									{
										ctor: '::',
										_0: _elm_lang$html$Html$text('New Tag'),
										_1: {ctor: '[]'}
									}),
								_1: {
									ctor: '::',
									_0: _elm_lang$html$Html$text(' field. So I\'ve added the tag '),
									_1: {
										ctor: '::',
										_0: _user$project$Pile_Bulma$readOnlyTag(_p0._0),
										_1: {
											ctor: '::',
											_0: _elm_lang$html$Html$text(' for you.'),
											_1: {
												ctor: '::',
												_0: _elm_lang$html$Html$text(' You can delete it if I goofed.'),
												_1: {ctor: '[]'}
											}
										}
									}
								}
							}
						}
					}
				});
		}
	});
var _user$project$Animals_Animal_Flash$SavedIncompleteTag = function (a) {
	return {ctor: 'SavedIncompleteTag', _0: a};
};
var _user$project$Animals_Animal_Flash$NoFlash = {ctor: 'NoFlash'};

var _user$project$Animals_Animal_Types$Animal = F6(
	function (a, b, c, d, e, f) {
		return {id: a, version: b, name: c, species: d, tags: e, properties: f};
	});
var _user$project$Animals_Animal_Types$Form = F6(
	function (a, b, c, d, e, f) {
		return {id: a, name: b, tags: c, tentativeTag: d, properties: e, isValid: f};
	});
var _user$project$Animals_Animal_Types$DisplayedAnimal = F3(
	function (a, b, c) {
		return {animal: a, format: b, animalFlash: c};
	});
var _user$project$Animals_Animal_Types$ValidationContext = function (a) {
	return {disallowedNames: a};
};
var _user$project$Animals_Animal_Types$AsBool = F2(
	function (a, b) {
		return {ctor: 'AsBool', _0: a, _1: b};
	});
var _user$project$Animals_Animal_Types$AsDate = F2(
	function (a, b) {
		return {ctor: 'AsDate', _0: a, _1: b};
	});
var _user$project$Animals_Animal_Types$AsString = F2(
	function (a, b) {
		return {ctor: 'AsString', _0: a, _1: b};
	});
var _user$project$Animals_Animal_Types$AsFloat = F2(
	function (a, b) {
		return {ctor: 'AsFloat', _0: a, _1: b};
	});
var _user$project$Animals_Animal_Types$AsInt = F2(
	function (a, b) {
		return {ctor: 'AsInt', _0: a, _1: b};
	});
var _user$project$Animals_Animal_Types$Editable = {ctor: 'Editable'};
var _user$project$Animals_Animal_Types$Expanded = {ctor: 'Expanded'};
var _user$project$Animals_Animal_Types$Compact = {ctor: 'Compact'};

var _user$project$Animals_OutsideWorld_Declare$AnimalUpdated = F2(
	function (a, b) {
		return {ctor: 'AnimalUpdated', _0: a, _1: b};
	});
var _user$project$Animals_OutsideWorld_Declare$AnimalCreated = F2(
	function (a, b) {
		return {ctor: 'AnimalCreated', _0: a, _1: b};
	});

var _user$project$Animals_Msg$NoOp = {ctor: 'NoOp'};
var _user$project$Animals_Msg$RemoveFlash = function (a) {
	return {ctor: 'RemoveFlash', _0: a};
};
var _user$project$Animals_Msg$MoreLikeThisAnimal = function (a) {
	return {ctor: 'MoreLikeThisAnimal', _0: a};
};
var _user$project$Animals_Msg$AddNewAnimals = F2(
	function (a, b) {
		return {ctor: 'AddNewAnimals', _0: a, _1: b};
	});
var _user$project$Animals_Msg$NoticeAnimalCreationResults = function (a) {
	return {ctor: 'NoticeAnimalCreationResults', _0: a};
};
var _user$project$Animals_Msg$NoticeAnimalSaveResults = function (a) {
	return {ctor: 'NoticeAnimalSaveResults', _0: a};
};
var _user$project$Animals_Msg$StartCreatingNewAnimal = F2(
	function (a, b) {
		return {ctor: 'StartCreatingNewAnimal', _0: a, _1: b};
	});
var _user$project$Animals_Msg$StartSavingAnimalEdits = F2(
	function (a, b) {
		return {ctor: 'StartSavingAnimalEdits', _0: a, _1: b};
	});
var _user$project$Animals_Msg$CancelAnimalCreation = F2(
	function (a, b) {
		return {ctor: 'CancelAnimalCreation', _0: a, _1: b};
	});
var _user$project$Animals_Msg$CancelAnimalEdits = F2(
	function (a, b) {
		return {ctor: 'CancelAnimalEdits', _0: a, _1: b};
	});
var _user$project$Animals_Msg$CheckFormChange = F2(
	function (a, b) {
		return {ctor: 'CheckFormChange', _0: a, _1: b};
	});
var _user$project$Animals_Msg$SwitchToEditView = function (a) {
	return {ctor: 'SwitchToEditView', _0: a};
};
var _user$project$Animals_Msg$SwitchToReadOnlyAnimalView = F2(
	function (a, b) {
		return {ctor: 'SwitchToReadOnlyAnimalView', _0: a, _1: b};
	});
var _user$project$Animals_Msg$SetSpeciesFilter = function (a) {
	return {ctor: 'SetSpeciesFilter', _0: a};
};
var _user$project$Animals_Msg$SetTagFilter = function (a) {
	return {ctor: 'SetTagFilter', _0: a};
};
var _user$project$Animals_Msg$SetNameFilter = function (a) {
	return {ctor: 'SetNameFilter', _0: a};
};
var _user$project$Animals_Msg$SelectDate = function (a) {
	return {ctor: 'SelectDate', _0: a};
};
var _user$project$Animals_Msg$ToggleDatePicker = {ctor: 'ToggleDatePicker'};
var _user$project$Animals_Msg$SetAnimals = function (a) {
	return {ctor: 'SetAnimals', _0: a};
};
var _user$project$Animals_Msg$SetToday = function (a) {
	return {ctor: 'SetToday', _0: a};
};
var _user$project$Animals_Msg$StartPageChange = function (a) {
	return {ctor: 'StartPageChange', _0: a};
};
var _user$project$Animals_Msg$NoticePageChange = function (a) {
	return {ctor: 'NoticePageChange', _0: a};
};

var _user$project$Animals_OutsideWorld_Json$encodeProperties = function (valueEncoder) {
	var encodeKV = function (_p0) {
		var _p1 = _p0;
		return {
			ctor: '_Tuple2',
			_0: _p1._0,
			_1: _elm_lang$core$Json_Encode$list(
				{
					ctor: '::',
					_0: valueEncoder(_p1._1._0),
					_1: {
						ctor: '::',
						_0: _elm_lang$core$Json_Encode$string(_p1._1._1),
						_1: {ctor: '[]'}
					}
				})
		};
	};
	return function (_p2) {
		return _elm_lang$core$Json_Encode$object(
			A2(
				_elm_lang$core$List$map,
				encodeKV,
				_elm_lang$core$Dict$toList(_p2)));
	};
};
var _user$project$Animals_OutsideWorld_Json$decodeProperties = function (valueDecoder) {
	return _elm_lang$core$Json_Decode$dict(
		A3(
			_elm_lang$core$Json_Decode$map2,
			F2(
				function (v0, v1) {
					return {ctor: '_Tuple2', _0: v0, _1: v1};
				}),
			A2(_elm_lang$core$Json_Decode$index, 0, valueDecoder),
			A2(_elm_lang$core$Json_Decode$index, 1, _elm_lang$core$Json_Decode$string)));
};
var _user$project$Animals_OutsideWorld_Json$animalTransferFormat_to_Animal = function (incoming) {
	var dictify = F2(
		function (unionF, data) {
			return A2(
				_elm_lang$core$Dict$map,
				F2(
					function (_p3, tuple) {
						return A2(_elm_lang$core$Basics$uncurry, unionF, tuple);
					}),
				data);
		});
	var strings = A2(dictify, _user$project$Animals_Animal_Types$AsString, incoming.string_properties);
	var bools = A2(dictify, _user$project$Animals_Animal_Types$AsBool, incoming.bool_properties);
	var ints = A2(dictify, _user$project$Animals_Animal_Types$AsInt, incoming.int_properties);
	var combine = function (dicts) {
		return A3(
			_elm_lang$core$List$foldl,
			F2(
				function (one, many) {
					return A2(_elm_lang$core$Dict$union, many, one);
				}),
			_elm_lang$core$Dict$empty,
			dicts);
	};
	var properties = combine(
		{
			ctor: '::',
			_0: ints,
			_1: {
				ctor: '::',
				_0: bools,
				_1: {
					ctor: '::',
					_0: strings,
					_1: {ctor: '[]'}
				}
			}
		});
	return {
		id: _elm_lang$core$Basics$toString(incoming.id),
		version: incoming.version,
		name: incoming.name,
		species: incoming.species,
		tags: incoming.tags,
		properties: properties
	};
};
var _user$project$Animals_OutsideWorld_Json$animal_to_animalTransferFormat = function (animal) {
	var intId = A2(
		_elm_lang$core$Result$withDefault,
		-1,
		_elm_lang$core$String$toInt(animal.id));
	return {id: intId, version: animal.version, name: animal.name, species: animal.species, tags: animal.tags, bool_properties: _elm_lang$core$Dict$empty, int_properties: _elm_lang$core$Dict$empty, string_properties: _elm_lang$core$Dict$empty};
};
var _user$project$Animals_OutsideWorld_Json$animalTransferFormat_to_json = function (xfer) {
	return _elm_lang$core$Json_Encode$object(
		{
			ctor: '::',
			_0: {
				ctor: '_Tuple2',
				_0: 'id',
				_1: _elm_lang$core$Json_Encode$int(xfer.id)
			},
			_1: {
				ctor: '::',
				_0: {
					ctor: '_Tuple2',
					_0: 'version',
					_1: _elm_lang$core$Json_Encode$int(xfer.version)
				},
				_1: {
					ctor: '::',
					_0: {
						ctor: '_Tuple2',
						_0: 'name',
						_1: _elm_lang$core$Json_Encode$string(xfer.name)
					},
					_1: {
						ctor: '::',
						_0: {
							ctor: '_Tuple2',
							_0: 'species',
							_1: _elm_lang$core$Json_Encode$string(xfer.species)
						},
						_1: {
							ctor: '::',
							_0: {
								ctor: '_Tuple2',
								_0: 'tags',
								_1: _elm_lang$core$Json_Encode$list(
									A2(_elm_lang$core$List$map, _elm_lang$core$Json_Encode$string, xfer.tags))
							},
							_1: {
								ctor: '::',
								_0: {
									ctor: '_Tuple2',
									_0: 'bool_properties',
									_1: A2(_user$project$Animals_OutsideWorld_Json$encodeProperties, _elm_lang$core$Json_Encode$bool, xfer.bool_properties)
								},
								_1: {
									ctor: '::',
									_0: {
										ctor: '_Tuple2',
										_0: 'int_properties',
										_1: A2(_user$project$Animals_OutsideWorld_Json$encodeProperties, _elm_lang$core$Json_Encode$int, xfer.int_properties)
									},
									_1: {
										ctor: '::',
										_0: {
											ctor: '_Tuple2',
											_0: 'string_properties',
											_1: A2(_user$project$Animals_OutsideWorld_Json$encodeProperties, _elm_lang$core$Json_Encode$string, xfer.string_properties)
										},
										_1: {ctor: '[]'}
									}
								}
							}
						}
					}
				}
			}
		});
};
var _user$project$Animals_OutsideWorld_Json$decodeCreationResult = function () {
	var from_transferFormat = function (_p4) {
		var _p5 = _p4;
		return A2(
			_user$project$Animals_OutsideWorld_Declare$AnimalCreated,
			_p5._0,
			_elm_lang$core$Basics$toString(_p5._1));
	};
	var to_transferFormat = A3(
		_elm_lang$core$Json_Decode$map2,
		F2(
			function (v0, v1) {
				return {ctor: '_Tuple2', _0: v0, _1: v1};
			}),
		A2(_elm_lang$core$Json_Decode$field, 'originalId', _elm_lang$core$Json_Decode$string),
		A2(_elm_lang$core$Json_Decode$field, 'serverId', _elm_lang$core$Json_Decode$int));
	return A2(_elm_lang$core$Json_Decode$map, from_transferFormat, to_transferFormat);
}();
var _user$project$Animals_OutsideWorld_Json$decodeSaveResult = function () {
	var from_transferFormat = function (_p6) {
		var _p7 = _p6;
		return A2(
			_user$project$Animals_OutsideWorld_Declare$AnimalUpdated,
			_elm_lang$core$Basics$toString(_p7._0),
			_p7._1);
	};
	var to_transferFormat = A3(
		_elm_lang$core$Json_Decode$map2,
		F2(
			function (v0, v1) {
				return {ctor: '_Tuple2', _0: v0, _1: v1};
			}),
		A2(_elm_lang$core$Json_Decode$field, 'id', _elm_lang$core$Json_Decode$int),
		A2(_elm_lang$core$Json_Decode$field, 'version', _elm_lang$core$Json_Decode$int));
	return A2(_elm_lang$core$Json_Decode$map, from_transferFormat, to_transferFormat);
}();
var _user$project$Animals_OutsideWorld_Json$encodeAnimal = function (_p8) {
	return _user$project$Animals_OutsideWorld_Json$animalTransferFormat_to_json(
		_user$project$Animals_OutsideWorld_Json$animal_to_animalTransferFormat(_p8));
};
var _user$project$Animals_OutsideWorld_Json$asData = function (v) {
	return _elm_lang$core$Json_Encode$object(
		{
			ctor: '::',
			_0: {ctor: '_Tuple2', _0: 'data', _1: v},
			_1: {ctor: '[]'}
		});
};
var _user$project$Animals_OutsideWorld_Json$withinData = _elm_lang$core$Json_Decode$at(
	{
		ctor: '::',
		_0: 'data',
		_1: {ctor: '[]'}
	});
var _user$project$Animals_OutsideWorld_Json$AnimalTransferFormat = F8(
	function (a, b, c, d, e, f, g, h) {
		return {id: a, version: b, name: c, species: d, tags: e, int_properties: f, bool_properties: g, string_properties: h};
	});
var _user$project$Animals_OutsideWorld_Json$json_to_AnimalTransferFormat = A9(
	_elm_lang$core$Json_Decode$map8,
	_user$project$Animals_OutsideWorld_Json$AnimalTransferFormat,
	A2(_elm_lang$core$Json_Decode$field, 'id', _elm_lang$core$Json_Decode$int),
	A2(_elm_lang$core$Json_Decode$field, 'version', _elm_lang$core$Json_Decode$int),
	A2(_elm_lang$core$Json_Decode$field, 'name', _elm_lang$core$Json_Decode$string),
	A2(_elm_lang$core$Json_Decode$field, 'species', _elm_lang$core$Json_Decode$string),
	A2(
		_elm_lang$core$Json_Decode$field,
		'tags',
		_elm_lang$core$Json_Decode$list(_elm_lang$core$Json_Decode$string)),
	A2(
		_elm_lang$core$Json_Decode$field,
		'int_properties',
		_user$project$Animals_OutsideWorld_Json$decodeProperties(_elm_lang$core$Json_Decode$int)),
	A2(
		_elm_lang$core$Json_Decode$field,
		'bool_properties',
		_user$project$Animals_OutsideWorld_Json$decodeProperties(_elm_lang$core$Json_Decode$bool)),
	A2(
		_elm_lang$core$Json_Decode$field,
		'string_properties',
		_user$project$Animals_OutsideWorld_Json$decodeProperties(_elm_lang$core$Json_Decode$string)));
var _user$project$Animals_OutsideWorld_Json$decodeAnimal = A2(_elm_lang$core$Json_Decode$map, _user$project$Animals_OutsideWorld_Json$animalTransferFormat_to_Animal, _user$project$Animals_OutsideWorld_Json$json_to_AnimalTransferFormat);
var _user$project$Animals_OutsideWorld_Json$decodeAnimals = _elm_lang$core$Json_Decode$list(_user$project$Animals_OutsideWorld_Json$decodeAnimal);

var _user$project$Animals_OutsideWorld_Define$createAnimal = function (animal) {
	var body = _elm_lang$http$Http$jsonBody(
		_user$project$Animals_OutsideWorld_Json$asData(
			_user$project$Animals_OutsideWorld_Json$encodeAnimal(animal)));
	var url = A2(_elm_lang$core$Basics_ops['++'], '/api/v2animals/create/', animal.id);
	var request = A3(
		_elm_lang$http$Http$post,
		url,
		body,
		_user$project$Animals_OutsideWorld_Json$withinData(_user$project$Animals_OutsideWorld_Json$decodeCreationResult));
	return A2(_elm_lang$http$Http$send, _user$project$Animals_Msg$NoticeAnimalCreationResults, request);
};
var _user$project$Animals_OutsideWorld_Define$saveAnimal = function (animal) {
	var body = _elm_lang$http$Http$jsonBody(
		_user$project$Animals_OutsideWorld_Json$asData(
			_user$project$Animals_OutsideWorld_Json$encodeAnimal(animal)));
	var url = '/api/v2animals/';
	var request = A3(
		_elm_lang$http$Http$post,
		url,
		body,
		_user$project$Animals_OutsideWorld_Json$withinData(_user$project$Animals_OutsideWorld_Json$decodeSaveResult));
	return A2(_elm_lang$http$Http$send, _user$project$Animals_Msg$NoticeAnimalSaveResults, request);
};
var _user$project$Animals_OutsideWorld_Define$fetchAnimals = function () {
	var url = '/api/v2animals';
	var request = A2(
		_elm_lang$http$Http$get,
		url,
		_user$project$Animals_OutsideWorld_Json$withinData(_user$project$Animals_OutsideWorld_Json$decodeAnimals));
	return A2(_elm_lang$http$Http$send, _user$project$Animals_Msg$SetAnimals, request);
}();
var _user$project$Animals_OutsideWorld_Define$askTodaysDate = A2(
	_elm_lang$core$Task$perform,
	function (_p0) {
		return _user$project$Animals_Msg$SetToday(
			_elm_lang$core$Maybe$Just(_p0));
	},
	_elm_lang$core$Date$now);

var _user$project$Pile_UpdatingLens$lensUpdate = F4(
	function (getPart, setPart, partTransformer, whole) {
		return A2(
			setPart,
			partTransformer(
				getPart(whole)),
			whole);
	});
var _user$project$Pile_UpdatingLens$toMonocle = function (u) {
	return {get: u.get, set: u.set};
};
var _user$project$Pile_UpdatingLens$lens = F2(
	function (getPart, setPart) {
		return {
			get: getPart,
			set: setPart,
			update: A2(_user$project$Pile_UpdatingLens$lensUpdate, getPart, setPart)
		};
	});
var _user$project$Pile_UpdatingLens$compose = F2(
	function (left, right) {
		var right_ = _user$project$Pile_UpdatingLens$toMonocle(right);
		var left_ = _user$project$Pile_UpdatingLens$toMonocle(left);
		var composed = A2(_arturopala$elm_monocle$Monocle_Lens$compose, left_, right_);
		return A2(_user$project$Pile_UpdatingLens$lens, composed.get, composed.set);
	});
var _user$project$Pile_UpdatingLens$UpdatingLens = F3(
	function (a, b, c) {
		return {get: a, set: b, update: c};
	});

var _user$project$Animals_Animal_Lenses$validationForm_maySave = A2(
	_user$project$Pile_UpdatingLens$lens,
	function (_) {
		return _.maySave;
	},
	F2(
		function (p, w) {
			return _elm_lang$core$Native_Utils.update(
				w,
				{maySave: p});
		}));
var _user$project$Animals_Animal_Lenses$validationForm_name = A2(
	_user$project$Pile_UpdatingLens$lens,
	function (_) {
		return _.name;
	},
	F2(
		function (p, w) {
			return _elm_lang$core$Native_Utils.update(
				w,
				{name: p});
		}));
var _user$project$Animals_Animal_Lenses$validationContext_disallowedNames = A2(
	_user$project$Pile_UpdatingLens$lens,
	function (_) {
		return _.disallowedNames;
	},
	F2(
		function (p, w) {
			return _elm_lang$core$Native_Utils.update(
				w,
				{disallowedNames: p});
		}));
var _user$project$Animals_Animal_Lenses$form_isValid = A2(
	_user$project$Pile_UpdatingLens$lens,
	function (_) {
		return _.isValid;
	},
	F2(
		function (p, w) {
			return _elm_lang$core$Native_Utils.update(
				w,
				{isValid: p});
		}));
var _user$project$Animals_Animal_Lenses$form_tentativeTag = A2(
	_user$project$Pile_UpdatingLens$lens,
	function (_) {
		return _.tentativeTag;
	},
	F2(
		function (p, w) {
			return _elm_lang$core$Native_Utils.update(
				w,
				{tentativeTag: p});
		}));
var _user$project$Animals_Animal_Lenses$form_tags = A2(
	_user$project$Pile_UpdatingLens$lens,
	function (_) {
		return _.tags;
	},
	F2(
		function (p, w) {
			return _elm_lang$core$Native_Utils.update(
				w,
				{tags: p});
		}));
var _user$project$Animals_Animal_Lenses$form_name = A2(
	_user$project$Pile_UpdatingLens$lens,
	function (_) {
		return _.name;
	},
	F2(
		function (p, w) {
			return _elm_lang$core$Native_Utils.update(
				w,
				{name: p});
		}));
var _user$project$Animals_Animal_Lenses$form_id = A2(
	_user$project$Pile_UpdatingLens$lens,
	function (_) {
		return _.id;
	},
	F2(
		function (p, w) {
			return _elm_lang$core$Native_Utils.update(
				w,
				{id: p});
		}));
var _user$project$Animals_Animal_Lenses$displayedAnimal_flash = A2(
	_user$project$Pile_UpdatingLens$lens,
	function (_) {
		return _.animalFlash;
	},
	F2(
		function (p, w) {
			return _elm_lang$core$Native_Utils.update(
				w,
				{animalFlash: p});
		}));
var _user$project$Animals_Animal_Lenses$displayedAnimal_format = A2(
	_user$project$Pile_UpdatingLens$lens,
	function (_) {
		return _.format;
	},
	F2(
		function (p, w) {
			return _elm_lang$core$Native_Utils.update(
				w,
				{format: p});
		}));
var _user$project$Animals_Animal_Lenses$displayedAnimal_animal = A2(
	_user$project$Pile_UpdatingLens$lens,
	function (_) {
		return _.animal;
	},
	F2(
		function (p, w) {
			return _elm_lang$core$Native_Utils.update(
				w,
				{animal: p});
		}));
var _user$project$Animals_Animal_Lenses$display_flash = A2(
	_user$project$Pile_UpdatingLens$lens,
	function (_) {
		return _.animalFlash;
	},
	F2(
		function (p, w) {
			return _elm_lang$core$Native_Utils.update(
				w,
				{animalFlash: p});
		}));
var _user$project$Animals_Animal_Lenses$animal_properties = A2(
	_user$project$Pile_UpdatingLens$lens,
	function (_) {
		return _.properties;
	},
	F2(
		function (p, w) {
			return _elm_lang$core$Native_Utils.update(
				w,
				{properties: p});
		}));
var _user$project$Animals_Animal_Lenses$animal_tags = A2(
	_user$project$Pile_UpdatingLens$lens,
	function (_) {
		return _.tags;
	},
	F2(
		function (p, w) {
			return _elm_lang$core$Native_Utils.update(
				w,
				{tags: p});
		}));
var _user$project$Animals_Animal_Lenses$animal_name = A2(
	_user$project$Pile_UpdatingLens$lens,
	function (_) {
		return _.name;
	},
	F2(
		function (p, w) {
			return _elm_lang$core$Native_Utils.update(
				w,
				{name: p});
		}));
var _user$project$Animals_Animal_Lenses$displayedAnimal_name = A2(_user$project$Pile_UpdatingLens$compose, _user$project$Animals_Animal_Lenses$displayedAnimal_animal, _user$project$Animals_Animal_Lenses$animal_name);
var _user$project$Animals_Animal_Lenses$animal_version = A2(
	_user$project$Pile_UpdatingLens$lens,
	function (_) {
		return _.version;
	},
	F2(
		function (p, w) {
			return _elm_lang$core$Native_Utils.update(
				w,
				{version: p});
		}));
var _user$project$Animals_Animal_Lenses$animal_id = A2(
	_user$project$Pile_UpdatingLens$lens,
	function (_) {
		return _.id;
	},
	F2(
		function (p, w) {
			return _elm_lang$core$Native_Utils.update(
				w,
				{id: p});
		}));
var _user$project$Animals_Animal_Lenses$displayedAnimal_id = A2(_user$project$Pile_UpdatingLens$compose, _user$project$Animals_Animal_Lenses$displayedAnimal_animal, _user$project$Animals_Animal_Lenses$animal_id);

var _user$project$Animals_Animal_Constructors$fresh = F2(
	function (species, id) {
		return {
			id: id,
			version: 0,
			name: '',
			species: species,
			tags: {ctor: '[]'},
			properties: _elm_lang$core$Dict$empty
		};
	});
var _user$project$Animals_Animal_Constructors$andFlash = F2(
	function (flash, animal) {
		return A2(_user$project$Animals_Animal_Lenses$displayedAnimal_flash.set, flash, animal);
	});
var _user$project$Animals_Animal_Constructors$noFlash = _user$project$Animals_Animal_Constructors$andFlash(_user$project$Animals_Animal_Flash$NoFlash);
var _user$project$Animals_Animal_Constructors$editable = function (animal) {
	return A3(_user$project$Animals_Animal_Types$DisplayedAnimal, animal, _user$project$Animals_Animal_Types$Editable, _user$project$Animals_Animal_Flash$NoFlash);
};
var _user$project$Animals_Animal_Constructors$expanded = function (animal) {
	return A3(_user$project$Animals_Animal_Types$DisplayedAnimal, animal, _user$project$Animals_Animal_Types$Expanded, _user$project$Animals_Animal_Flash$NoFlash);
};
var _user$project$Animals_Animal_Constructors$compact = function (animal) {
	return A3(_user$project$Animals_Animal_Types$DisplayedAnimal, animal, _user$project$Animals_Animal_Types$Compact, _user$project$Animals_Animal_Flash$NoFlash);
};

var _user$project$Animals_Animal_Form$applyEditsToAnimal = F2(
	function (animal, form) {
		var update = function (tags) {
			return A2(
				_user$project$Animals_Animal_Lenses$animal_tags.set,
				tags,
				A2(
					_user$project$Animals_Animal_Lenses$animal_properties.set,
					form.properties,
					A2(_user$project$Animals_Animal_Lenses$animal_name.set, form.name.value, animal)));
		};
		var _p0 = _elm_lang$core$String$isEmpty(form.tentativeTag);
		if (_p0 === true) {
			return {
				ctor: '_Tuple2',
				_0: update(form.tags),
				_1: _user$project$Animals_Animal_Flash$NoFlash
			};
		} else {
			return {
				ctor: '_Tuple2',
				_0: update(
					A2(
						_elm_lang$core$List$append,
						form.tags,
						{
							ctor: '::',
							_0: form.tentativeTag,
							_1: {ctor: '[]'}
						})),
				_1: _user$project$Animals_Animal_Flash$SavedIncompleteTag(form.tentativeTag)
			};
		}
	});
var _user$project$Animals_Animal_Form$freshValue = function (v) {
	return A3(
		_user$project$Pile_Bulma$FormValue,
		_user$project$Pile_Bulma$Valid,
		v,
		{ctor: '[]'});
};
var _user$project$Animals_Animal_Form$extractForm = function (animal) {
	return {
		isValid: true,
		id: animal.id,
		name: _user$project$Animals_Animal_Form$freshValue(animal.name),
		tags: animal.tags,
		tentativeTag: '',
		properties: animal.properties
	};
};
var _user$project$Animals_Animal_Form$nullForm = {
	isValid: false,
	id: 'impossible',
	name: _user$project$Animals_Animal_Form$freshValue('you should never see this'),
	tags: {ctor: '[]'},
	tentativeTag: '',
	properties: _elm_lang$core$Dict$empty
};
var _user$project$Animals_Animal_Form$textFieldEditHandler = F3(
	function (displayed, form, lens) {
		var newStringToValidate = function (string) {
			return A2(
				lens.set,
				_user$project$Animals_Animal_Form$freshValue(string),
				form);
		};
		return function (_p1) {
			return A2(
				_user$project$Animals_Msg$CheckFormChange,
				displayed,
				newStringToValidate(_p1));
		};
	});

var _user$project$Animals_Pages_Define$fromLocation = function (location) {
	var path = location.pathname;
	return A2(_elm_lang$core$String$startsWith, _user$project$Animals_Pages_Declare$addPagePath, path) ? _user$project$Animals_Pages_Declare$AddPage : (A2(_elm_lang$core$String$startsWith, _user$project$Animals_Pages_Declare$helpPagePath, path) ? _user$project$Animals_Pages_Declare$HelpPage : _user$project$Animals_Pages_Declare$AllPage);
};
var _user$project$Animals_Pages_Define$toPageChangeCmd = function (page) {
	var url = function () {
		var _p0 = page;
		switch (_p0.ctor) {
			case 'AllPage':
				return _user$project$Animals_Pages_Declare$allPagePath;
			case 'AddPage':
				return _user$project$Animals_Pages_Declare$addPagePath;
			default:
				return _user$project$Animals_Pages_Declare$helpPagePath;
		}
	}();
	return _elm_lang$navigation$Navigation$newUrl(url);
};

var _user$project$Animals_Pages_PageFlash$httpError = F2(
	function (contextString, err) {
		var paddedContext = A2(_elm_lang$core$Basics_ops['++'], contextString, ' ');
		var errText = function () {
			var _p0 = err;
			switch (_p0.ctor) {
				case 'BadUrl':
					return {
						ctor: '::',
						_0: _elm_lang$html$Html$text('Something is wrong with this app. It created a bad web address'),
						_1: {
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$p,
								{ctor: '[]'},
								{
									ctor: '::',
									_0: _elm_lang$html$Html$text('Details: '),
									_1: {
										ctor: '::',
										_0: _elm_lang$html$Html$text(_p0._0),
										_1: {ctor: '[]'}
									}
								}),
							_1: {ctor: '[]'}
						}
					};
				case 'Timeout':
					return {
						ctor: '::',
						_0: _elm_lang$html$Html$text('The server did not respond. Try again later?'),
						_1: {ctor: '[]'}
					};
				case 'NetworkError':
					return {
						ctor: '::',
						_0: _elm_lang$html$Html$text('The network seems unavailable.'),
						_1: {ctor: '[]'}
					};
				case 'BadStatus':
					return {
						ctor: '::',
						_0: _elm_lang$html$Html$text('The server declared that it could not respond.'),
						_1: {
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$p,
								{ctor: '[]'},
								{
									ctor: '::',
									_0: _elm_lang$html$Html$text('Details: '),
									_1: {
										ctor: '::',
										_0: _elm_lang$html$Html$text(_p0._0.status.message),
										_1: {ctor: '[]'}
									}
								}),
							_1: {ctor: '[]'}
						}
					};
				default:
					return {
						ctor: '::',
						_0: _elm_lang$html$Html$text('The server returned nonsensical results.'),
						_1: {
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$p,
								{ctor: '[]'},
								{
									ctor: '::',
									_0: _elm_lang$html$Html$text('Details: '),
									_1: {
										ctor: '::',
										_0: _elm_lang$html$Html$text(_p0._0),
										_1: {ctor: '[]'}
									}
								}),
							_1: {ctor: '[]'}
						}
					};
			}
		}();
		return A2(
			_user$project$Pile_Bulma$flashNotification,
			_user$project$Animals_Msg$NoOp,
			{
				ctor: '::',
				_0: _elm_lang$html$Html$text(paddedContext),
				_1: errText
			});
	});
var _user$project$Animals_Pages_PageFlash$show = function (flash) {
	var _p1 = flash;
	switch (_p1.ctor) {
		case 'NoFlash':
			return A2(
				_elm_lang$html$Html$span,
				{ctor: '[]'},
				{ctor: '[]'});
		case 'SavedAnimalFlash':
			return A2(
				_user$project$Pile_Bulma$flashNotification,
				_user$project$Animals_Msg$NoOp,
				{
					ctor: '::',
					_0: _elm_lang$html$Html$text('The new animal can be seen on the '),
					_1: {
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$a,
							{
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$href(_user$project$Animals_Pages_Declare$allPagePath),
								_1: {ctor: '[]'}
							},
							{
								ctor: '::',
								_0: _elm_lang$html$Html$text('View Animals'),
								_1: {ctor: '[]'}
							}),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html$text(' page.'),
							_1: {ctor: '[]'}
						}
					}
				});
		default:
			return A2(_user$project$Animals_Pages_PageFlash$httpError, _p1._0, _p1._1);
	}
};
var _user$project$Animals_Pages_PageFlash$HttpErrorFlash = F2(
	function (a, b) {
		return {ctor: 'HttpErrorFlash', _0: a, _1: b};
	});
var _user$project$Animals_Pages_PageFlash$SavedAnimalFlash = {ctor: 'SavedAnimalFlash'};
var _user$project$Animals_Pages_PageFlash$NoFlash = {ctor: 'NoFlash'};

var _user$project$Pile_Calendar$visibilityController = F3(
	function (calendarToggleMsg, control, maybeContent) {
		var controlContainer = A2(
			_elm_lang$html$Html$div,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class('dropdown--button-container'),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: control,
				_1: {ctor: '[]'}
			});
		var _p0 = maybeContent;
		if (_p0.ctor === 'Nothing') {
			return A2(
				_elm_lang$html$Html$div,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('dropdown'),
					_1: {ctor: '[]'}
				},
				{
					ctor: '::',
					_0: controlContainer,
					_1: {ctor: '[]'}
				});
		} else {
			return A2(
				_elm_lang$html$Html$div,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('dropdown-open'),
					_1: {ctor: '[]'}
				},
				{
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$div,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class('dropdown--page-cover'),
							_1: {
								ctor: '::',
								_0: _elm_lang$html$Html_Events$onClick(calendarToggleMsg),
								_1: {ctor: '[]'}
							}
						},
						{ctor: '[]'}),
					_1: {
						ctor: '::',
						_0: controlContainer,
						_1: {
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$div,
								{
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$class('dropdown--content-container'),
									_1: {ctor: '[]'}
								},
								{
									ctor: '::',
									_0: _p0._0,
									_1: {ctor: '[]'}
								}),
							_1: {ctor: '[]'}
						}
					}
				});
		}
	});
var _user$project$Pile_Calendar$defaultDate = A3(_justinmimbs$elm_date_extra$Date_Extra$fromCalendarDate, 2018, _elm_lang$core$Date$Jan, 1);
var _user$project$Pile_Calendar$dateToShow = function (edate) {
	var _p1 = edate.effectiveDate;
	if (_p1.ctor === 'Today') {
		return edate.today;
	} else {
		return _elm_lang$core$Maybe$Just(_p1._0);
	}
};
var _user$project$Pile_Calendar$bound = F2(
	function (shiftFunction, edate) {
		var shiftByYears = function (date) {
			return A3(
				_justinmimbs$elm_date_extra$Date_Extra$add,
				_justinmimbs$elm_date_extra$Date_Extra$Year,
				A2(shiftFunction, 0, 5),
				date);
		};
		var _p2 = _user$project$Pile_Calendar$dateToShow(edate);
		if (_p2.ctor === 'Nothing') {
			return shiftByYears(_user$project$Pile_Calendar$defaultDate);
		} else {
			return shiftByYears(_p2._0);
		}
	});
var _user$project$Pile_Calendar$enhancedDateString = function (edate) {
	var todayIfKnown = function () {
		var _p3 = edate.today;
		if (_p3.ctor === 'Nothing') {
			return '';
		} else {
			return A2(_justinmimbs$elm_date_extra$Date_Extra$toFormattedString, ' (MMM d)', _p3._0);
		}
	}();
	var _p4 = edate.effectiveDate;
	if (_p4.ctor === 'Today') {
		return A2(_elm_lang$core$Basics_ops['++'], 'Today', todayIfKnown);
	} else {
		return A2(_justinmimbs$elm_date_extra$Date_Extra$toFormattedString, 'MMM d, y', _p4._0);
	}
};
var _user$project$Pile_Calendar$view = F4(
	function (launcher, calendarToggleMsg, dateSelectedMsg, edate) {
		var selected = _user$project$Pile_Calendar$dateToShow(edate);
		var max = A2(
			_user$project$Pile_Calendar$bound,
			F2(
				function (x, y) {
					return x + y;
				}),
			edate);
		var min = A2(
			_user$project$Pile_Calendar$bound,
			F2(
				function (x, y) {
					return x - y;
				}),
			edate);
		var calendarBodyView = edate.datePickerOpen ? _elm_lang$core$Maybe$Just(
			A2(
				_elm_lang$virtual_dom$VirtualDom$map,
				dateSelectedMsg,
				A3(_justinmimbs$elm_date_selector$DateSelector$view, min, max, selected))) : _elm_lang$core$Maybe$Nothing;
		return A3(
			_user$project$Pile_Calendar$visibilityController,
			calendarToggleMsg,
			A3(
				launcher,
				edate.datePickerOpen,
				_user$project$Pile_Calendar$enhancedDateString(edate),
				calendarToggleMsg),
			calendarBodyView);
	});
var _user$project$Pile_Calendar$At = function (a) {
	return {ctor: 'At', _0: a};
};
var _user$project$Pile_Calendar$Today = {ctor: 'Today'};

var _user$project$Animals_Main$subscriptions = function (model) {
	return _elm_lang$core$Platform_Sub$none;
};
var _user$project$Animals_Main$noCmd = function (model) {
	return A2(
		_elm_lang$core$Platform_Cmd_ops['!'],
		model,
		{ctor: '[]'});
};
var _user$project$Animals_Main$populateAllAnimalsPage = F2(
	function (animals, model) {
		var displayedAnimals = A2(_elm_lang$core$List$map, _user$project$Animals_Animal_Constructors$compact, animals);
		var ids = A2(
			_elm_lang$core$List$map,
			function (_) {
				return _.id;
			},
			animals);
		return _elm_lang$core$Native_Utils.update(
			model,
			{
				animals: _elm_lang$core$Dict$fromList(
					A3(
						_elm_lang$core$List$map2,
						F2(
							function (v0, v1) {
								return {ctor: '_Tuple2', _0: v0, _1: v1};
							}),
						ids,
						displayedAnimals)),
				allPageAnimals: _elm_lang$core$Set$fromList(ids)
			});
	});
var _user$project$Animals_Main$setFormat = _user$project$Animals_Animal_Lenses$displayedAnimal_format.set;
var _user$project$Animals_Main$checkForm = F3(
	function (animal, form, model) {
		return form;
	});
var _user$project$Animals_Main$init = F2(
	function (flags, location) {
		var model = {
			page: _user$project$Animals_Pages_Define$fromLocation(location),
			pageFlash: _user$project$Animals_Pages_PageFlash$NoFlash,
			csrfToken: flags.csrfToken,
			animals: _elm_lang$core$Dict$empty,
			forms: _elm_lang$core$Dict$empty,
			allPageAnimals: _elm_lang$core$Set$empty,
			nameFilter: '',
			tagFilter: '',
			speciesFilter: '',
			effectiveDate: _user$project$Pile_Calendar$Today,
			today: _elm_lang$core$Maybe$Nothing,
			datePickerOpen: false,
			addPageAnimals: _elm_lang$core$Set$empty
		};
		return A2(
			_elm_lang$core$Platform_Cmd_ops['!'],
			model,
			{
				ctor: '::',
				_0: _user$project$Animals_OutsideWorld_Define$askTodaysDate,
				_1: {
					ctor: '::',
					_0: _user$project$Animals_OutsideWorld_Define$fetchAnimals,
					_1: {ctor: '[]'}
				}
			});
	});
var _user$project$Animals_Main$model_pageFlash = A2(
	_user$project$Pile_UpdatingLens$lens,
	function (_) {
		return _.pageFlash;
	},
	F2(
		function (p, w) {
			return _elm_lang$core$Native_Utils.update(
				w,
				{pageFlash: p});
		}));
var _user$project$Animals_Main$httpError = F3(
	function (contextString, err, model) {
		return A2(
			_user$project$Animals_Main$model_pageFlash.set,
			A2(_user$project$Animals_Pages_PageFlash$HttpErrorFlash, contextString, err),
			model);
	});
var _user$project$Animals_Main$model_datePickerOpen = A2(
	_user$project$Pile_UpdatingLens$lens,
	function (_) {
		return _.datePickerOpen;
	},
	F2(
		function (p, w) {
			return _elm_lang$core$Native_Utils.update(
				w,
				{datePickerOpen: p});
		}));
var _user$project$Animals_Main$model_effectiveDate = A2(
	_user$project$Pile_UpdatingLens$lens,
	function (_) {
		return _.effectiveDate;
	},
	F2(
		function (p, w) {
			return _elm_lang$core$Native_Utils.update(
				w,
				{effectiveDate: p});
		}));
var _user$project$Animals_Main$model_nameFilter = A2(
	_user$project$Pile_UpdatingLens$lens,
	function (_) {
		return _.nameFilter;
	},
	F2(
		function (p, w) {
			return _elm_lang$core$Native_Utils.update(
				w,
				{nameFilter: p});
		}));
var _user$project$Animals_Main$model_speciesFilter = A2(
	_user$project$Pile_UpdatingLens$lens,
	function (_) {
		return _.speciesFilter;
	},
	F2(
		function (p, w) {
			return _elm_lang$core$Native_Utils.update(
				w,
				{speciesFilter: p});
		}));
var _user$project$Animals_Main$model_tagFilter = A2(
	_user$project$Pile_UpdatingLens$lens,
	function (_) {
		return _.tagFilter;
	},
	F2(
		function (p, w) {
			return _elm_lang$core$Native_Utils.update(
				w,
				{tagFilter: p});
		}));
var _user$project$Animals_Main$model_forms = A2(
	_user$project$Pile_UpdatingLens$lens,
	function (_) {
		return _.forms;
	},
	F2(
		function (p, w) {
			return _elm_lang$core$Native_Utils.update(
				w,
				{forms: p});
		}));
var _user$project$Animals_Main$upsertForm = F2(
	function (form, model) {
		var key = _user$project$Animals_Animal_Lenses$form_id.get(form);
		var newForms = A3(_elm_lang$core$Dict$insert, key, form, model.forms);
		return A2(_user$project$Animals_Main$model_forms.set, newForms, model);
	});
var _user$project$Animals_Main$deleteForm = F2(
	function (form, model) {
		var key = _user$project$Animals_Animal_Lenses$form_id.get(form);
		return A2(
			_user$project$Animals_Main$model_forms.update,
			_elm_lang$core$Dict$remove(key),
			model);
	});
var _user$project$Animals_Main$model_addPageAnimals = A2(
	_user$project$Pile_UpdatingLens$lens,
	function (_) {
		return _.addPageAnimals;
	},
	F2(
		function (p, w) {
			return _elm_lang$core$Native_Utils.update(
				w,
				{addPageAnimals: p});
		}));
var _user$project$Animals_Main$model_allPageAnimals = A2(
	_user$project$Pile_UpdatingLens$lens,
	function (_) {
		return _.allPageAnimals;
	},
	F2(
		function (p, w) {
			return _elm_lang$core$Native_Utils.update(
				w,
				{allPageAnimals: p});
		}));
var _user$project$Animals_Main$model_animals = A2(
	_user$project$Pile_UpdatingLens$lens,
	function (_) {
		return _.animals;
	},
	F2(
		function (p, w) {
			return _elm_lang$core$Native_Utils.update(
				w,
				{animals: p});
		}));
var _user$project$Animals_Main$upsertAnimal = F2(
	function (displayedAnimal, model) {
		var key = _user$project$Animals_Animal_Lenses$displayedAnimal_id.get(displayedAnimal);
		var newAnimals = A3(_elm_lang$core$Dict$insert, key, displayedAnimal, model.animals);
		return A2(_user$project$Animals_Main$model_animals.set, newAnimals, model);
	});
var _user$project$Animals_Main$model_today = A2(
	_user$project$Pile_UpdatingLens$lens,
	function (_) {
		return _.today;
	},
	F2(
		function (p, w) {
			return _elm_lang$core$Native_Utils.update(
				w,
				{today: p});
		}));
var _user$project$Animals_Main$model_page = A2(
	_user$project$Pile_UpdatingLens$lens,
	function (_) {
		return _.page;
	},
	F2(
		function (p, w) {
			return _elm_lang$core$Native_Utils.update(
				w,
				{page: p});
		}));
var _user$project$Animals_Main$update_ = F2(
	function (msg, model) {
		var _p0 = msg;
		switch (_p0.ctor) {
			case 'NoticePageChange':
				return _user$project$Animals_Main$noCmd(
					A2(
						_user$project$Animals_Main$model_page.set,
						_user$project$Animals_Pages_Define$fromLocation(_p0._0),
						model));
			case 'StartPageChange':
				return {
					ctor: '_Tuple2',
					_0: model,
					_1: _user$project$Animals_Pages_Define$toPageChangeCmd(_p0._0)
				};
			case 'SetToday':
				return _user$project$Animals_Main$noCmd(
					A2(_user$project$Animals_Main$model_today.set, _p0._0, model));
			case 'SetAnimals':
				if (_p0._0.ctor === 'Ok') {
					return _user$project$Animals_Main$noCmd(
						A2(_user$project$Animals_Main$populateAllAnimalsPage, _p0._0._0, model));
				} else {
					return _user$project$Animals_Main$noCmd(
						A3(_user$project$Animals_Main$httpError, 'I could not retrieve animals.', _p0._0._0, model));
				}
			case 'ToggleDatePicker':
				return _user$project$Animals_Main$noCmd(
					A2(_user$project$Animals_Main$model_datePickerOpen.update, _elm_lang$core$Basics$not, model));
			case 'SelectDate':
				return _user$project$Animals_Main$noCmd(
					A2(
						_user$project$Animals_Main$model_effectiveDate.set,
						_user$project$Pile_Calendar$At(_p0._0),
						model));
			case 'SetNameFilter':
				return _user$project$Animals_Main$noCmd(
					A2(_user$project$Animals_Main$model_nameFilter.set, _p0._0, model));
			case 'SetTagFilter':
				return _user$project$Animals_Main$noCmd(
					A2(_user$project$Animals_Main$model_tagFilter.set, _p0._0, model));
			case 'SetSpeciesFilter':
				return _user$project$Animals_Main$noCmd(
					A2(_user$project$Animals_Main$model_speciesFilter.set, _p0._0, model));
			case 'SwitchToReadOnlyAnimalView':
				var newAnimal = A2(
					_user$project$Animals_Animal_Lenses$displayedAnimal_format.set,
					_p0._1,
					_user$project$Animals_Animal_Constructors$noFlash(_p0._0));
				return _user$project$Animals_Main$noCmd(
					A2(_user$project$Animals_Main$upsertAnimal, newAnimal, model));
			case 'SwitchToEditView':
				var _p1 = _p0._0;
				var form = _user$project$Animals_Animal_Form$extractForm(_p1.animal);
				var newAnimal = A2(
					_user$project$Animals_Animal_Lenses$displayedAnimal_format.set,
					_user$project$Animals_Animal_Types$Editable,
					_user$project$Animals_Animal_Constructors$noFlash(_p1));
				return _user$project$Animals_Main$noCmd(
					A2(
						_user$project$Animals_Main$upsertForm,
						form,
						A2(_user$project$Animals_Main$upsertAnimal, newAnimal, model)));
			case 'CheckFormChange':
				var newAnimal = _user$project$Animals_Animal_Constructors$noFlash(_p0._0);
				var newForm = A3(_user$project$Animals_Main$checkForm, newAnimal, _p0._1, model);
				return _user$project$Animals_Main$noCmd(
					A2(
						_user$project$Animals_Main$upsertForm,
						newForm,
						A2(_user$project$Animals_Main$upsertAnimal, newAnimal, model)));
			case 'CancelAnimalEdits':
				var $new = A2(
					_user$project$Animals_Animal_Lenses$displayedAnimal_format.set,
					_user$project$Animals_Animal_Types$Expanded,
					_user$project$Animals_Animal_Constructors$noFlash(_p0._0));
				return _user$project$Animals_Main$noCmd(
					A2(
						_user$project$Animals_Main$deleteForm,
						_p0._1,
						A2(_user$project$Animals_Main$upsertAnimal, $new, model)));
			case 'CancelAnimalCreation':
				return _user$project$Animals_Main$noCmd(model);
			case 'StartSavingAnimalEdits':
				return _user$project$Animals_Main$noCmd(model);
			case 'StartCreatingNewAnimal':
				return _user$project$Animals_Main$noCmd(model);
			case 'NoticeAnimalSaveResults':
				if (_p0._0.ctor === 'Ok') {
					return A2(
						_elm_lang$core$Platform_Cmd_ops['!'],
						model,
						{ctor: '[]'});
				} else {
					return _user$project$Animals_Main$noCmd(
						A3(_user$project$Animals_Main$httpError, 'I could not save the animal.', _p0._0._0, model));
				}
			case 'NoticeAnimalCreationResults':
				if (_p0._0.ctor === 'Ok') {
					return A2(
						_elm_lang$core$Platform_Cmd_ops['!'],
						model,
						{ctor: '[]'});
				} else {
					return _user$project$Animals_Main$noCmd(
						A3(_user$project$Animals_Main$httpError, 'I could not create the animal.', _p0._0._0, model));
				}
			case 'AddNewAnimals':
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					model,
					{ctor: '[]'});
			case 'MoreLikeThisAnimal':
				return _user$project$Animals_Main$noCmd(model);
			case 'RemoveFlash':
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					model,
					{ctor: '[]'});
			default:
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					model,
					{ctor: '[]'});
		}
	});
var _user$project$Animals_Main$update = F2(
	function (msg, model) {
		return A2(
			_user$project$Animals_Main$update_,
			msg,
			A2(_user$project$Animals_Main$model_pageFlash.set, _user$project$Animals_Pages_PageFlash$NoFlash, model));
	});
var _user$project$Animals_Main$Flags = function (a) {
	return {csrfToken: a};
};
var _user$project$Animals_Main$Model = function (a) {
	return function (b) {
		return function (c) {
			return function (d) {
				return function (e) {
					return function (f) {
						return function (g) {
							return function (h) {
								return function (i) {
									return function (j) {
										return function (k) {
											return function (l) {
												return function (m) {
													return {page: a, pageFlash: b, csrfToken: c, animals: d, forms: e, allPageAnimals: f, nameFilter: g, tagFilter: h, speciesFilter: i, effectiveDate: j, today: k, datePickerOpen: l, addPageAnimals: m};
												};
											};
										};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};

var _user$project$Animals_Animal_Icons$editHelp = function (iconType) {
	return A3(iconType, 'fa-question-circle', 'Help on editing', _user$project$Animals_Msg$NoOp);
};
var _user$project$Animals_Animal_Icons$moreLikeThis = F2(
	function (animal, iconType) {
		return A3(
			iconType,
			'fa-plus',
			'Copy: make more animals like this one',
			_user$project$Animals_Msg$MoreLikeThisAnimal(animal));
	});
var _user$project$Animals_Animal_Icons$edit = F2(
	function (animal, iconType) {
		return A3(
			iconType,
			'fa-pencil',
			'Edit: make changes to this animal',
			_user$project$Animals_Msg$SwitchToEditView(animal));
	});
var _user$project$Animals_Animal_Icons$contract = F2(
	function (animal, iconType) {
		return A3(
			iconType,
			'fa-caret-up',
			'Contract: show less about this animal',
			A2(_user$project$Animals_Msg$SwitchToReadOnlyAnimalView, animal, _user$project$Animals_Animal_Types$Compact));
	});
var _user$project$Animals_Animal_Icons$expand = F2(
	function (animal, iconType) {
		return A3(
			iconType,
			'fa-caret-down',
			'Expand: show more about this animal',
			A2(_user$project$Animals_Msg$SwitchToReadOnlyAnimalView, animal, _user$project$Animals_Animal_Types$Expanded));
	});

var _user$project$Animals_Animal_ReadOnlyViews$parentheticalSpecies = function (animal) {
	return A2(
		_elm_lang$core$Basics_ops['++'],
		' (',
		A2(_elm_lang$core$Basics_ops['++'], animal.species, ')'));
};
var _user$project$Animals_Animal_ReadOnlyViews$animalTags = function (animal) {
	return A2(_elm_lang$core$List$map, _user$project$Pile_Bulma$readOnlyTag, animal.tags);
};
var _user$project$Animals_Animal_ReadOnlyViews$animalSalutation = function (animal) {
	return _elm_lang$html$Html$text(
		A2(
			_elm_lang$core$Basics_ops['++'],
			_elm_community$string_extra$String_Extra$toSentenceCase(animal.name),
			_user$project$Animals_Animal_ReadOnlyViews$parentheticalSpecies(animal)));
};
var _user$project$Animals_Animal_ReadOnlyViews$boolExplanation = F2(
	function (b, explanation) {
		var suffix = function () {
			var _p0 = explanation;
			if (_p0 === '') {
				return '';
			} else {
				return A2(
					_elm_lang$core$Basics_ops['++'],
					' (',
					A2(_elm_lang$core$Basics_ops['++'], _p0, ')'));
			}
		}();
		var icon = function () {
			var _p1 = b;
			if (_p1 === true) {
				return _user$project$Pile_Bulma$trueIcon;
			} else {
				return _user$project$Pile_Bulma$falseIcon;
			}
		}();
		return {
			ctor: '::',
			_0: icon,
			_1: {
				ctor: '::',
				_0: _elm_lang$html$Html$text(suffix),
				_1: {ctor: '[]'}
			}
		};
	});
var _user$project$Animals_Animal_ReadOnlyViews$propertyDisplayValue = function (value) {
	var _p2 = value;
	switch (_p2.ctor) {
		case 'AsBool':
			return A2(_user$project$Animals_Animal_ReadOnlyViews$boolExplanation, _p2._0, _p2._1);
		case 'AsString':
			return {
				ctor: '::',
				_0: _elm_lang$html$Html$text(_p2._0),
				_1: {ctor: '[]'}
			};
		default:
			return {
				ctor: '::',
				_0: _elm_lang$html$Html$text('unimplemented'),
				_1: {ctor: '[]'}
			};
	}
};
var _user$project$Animals_Animal_ReadOnlyViews$animalProperties = function (animal) {
	var propertyPairs = _elm_lang$core$Dict$toList(animal.properties);
	var row = function (_p3) {
		var _p4 = _p3;
		return A2(
			_elm_lang$html$Html$tr,
			{ctor: '[]'},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$td,
					{ctor: '[]'},
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text(_p4._0),
						_1: {ctor: '[]'}
					}),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$td,
						{ctor: '[]'},
						_user$project$Animals_Animal_ReadOnlyViews$propertyDisplayValue(_p4._1)),
					_1: {ctor: '[]'}
				}
			});
	};
	return A2(_elm_lang$core$List$map, row, propertyPairs);
};
var _user$project$Animals_Animal_ReadOnlyViews$expandedView = function (displayedAnimal) {
	var flash = displayedAnimal.animalFlash;
	var animal = displayedAnimal.animal;
	return A2(
		_user$project$Pile_Bulma$highlightedRow,
		{ctor: '[]'},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$td,
				{ctor: '[]'},
				{
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$p,
						{ctor: '[]'},
						{
							ctor: '::',
							_0: _user$project$Animals_Animal_ReadOnlyViews$animalSalutation(animal),
							_1: {ctor: '[]'}
						}),
					_1: {
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$p,
							{ctor: '[]'},
							_user$project$Animals_Animal_ReadOnlyViews$animalTags(animal)),
						_1: {
							ctor: '::',
							_0: _user$project$Pile_Bulma$propertyTable(
								_user$project$Animals_Animal_ReadOnlyViews$animalProperties(animal)),
							_1: {
								ctor: '::',
								_0: A2(
									_user$project$Animals_Animal_Flash$showWithButton,
									flash,
									_user$project$Animals_Msg$RemoveFlash(displayedAnimal)),
								_1: {ctor: '[]'}
							}
						}
					}
				}),
			_1: {
				ctor: '::',
				_0: A2(_user$project$Animals_Animal_Icons$contract, displayedAnimal, _user$project$Pile_Bulma$tdIcon),
				_1: {
					ctor: '::',
					_0: A2(_user$project$Animals_Animal_Icons$edit, displayedAnimal, _user$project$Pile_Bulma$tdIcon),
					_1: {
						ctor: '::',
						_0: A2(_user$project$Animals_Animal_Icons$moreLikeThis, displayedAnimal, _user$project$Pile_Bulma$tdIcon),
						_1: {ctor: '[]'}
					}
				}
			}
		});
};
var _user$project$Animals_Animal_ReadOnlyViews$compactView = function (displayedAnimal) {
	var flash = displayedAnimal.animalFlash;
	var animal = displayedAnimal.animal;
	return A2(
		_elm_lang$html$Html$tr,
		{ctor: '[]'},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$td,
				{ctor: '[]'},
				{
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$p,
						{ctor: '[]'},
						{
							ctor: '::',
							_0: _user$project$Animals_Animal_ReadOnlyViews$animalSalutation(animal),
							_1: _user$project$Animals_Animal_ReadOnlyViews$animalTags(animal)
						}),
					_1: {
						ctor: '::',
						_0: A2(
							_user$project$Animals_Animal_Flash$showWithButton,
							flash,
							_user$project$Animals_Msg$RemoveFlash(displayedAnimal)),
						_1: {ctor: '[]'}
					}
				}),
			_1: {
				ctor: '::',
				_0: A2(_user$project$Animals_Animal_Icons$expand, displayedAnimal, _user$project$Pile_Bulma$tdIcon),
				_1: {
					ctor: '::',
					_0: A2(_user$project$Animals_Animal_Icons$edit, displayedAnimal, _user$project$Pile_Bulma$tdIcon),
					_1: {
						ctor: '::',
						_0: A2(_user$project$Animals_Animal_Icons$moreLikeThis, displayedAnimal, _user$project$Pile_Bulma$tdIcon),
						_1: {ctor: '[]'}
					}
				}
			}
		});
};

var _user$project$Animals_Animal_EditableView$newTagControl = F2(
	function (displayed, form) {
		var onSubmit = A2(
			_user$project$Animals_Msg$CheckFormChange,
			displayed,
			A2(
				_user$project$Animals_Animal_Lenses$form_tentativeTag.set,
				'',
				A2(
					_user$project$Animals_Animal_Lenses$form_tags.set,
					A2(
						_elm_lang$core$List$append,
						form.tags,
						{
							ctor: '::',
							_0: form.tentativeTag,
							_1: {ctor: '[]'}
						}),
					form)));
		var onInput = function (value) {
			return A2(
				_user$project$Animals_Msg$CheckFormChange,
				displayed,
				A2(_user$project$Animals_Animal_Lenses$form_tentativeTag.set, value, form));
		};
		return A4(_user$project$Pile_Bulma$textInputWithSubmit, 'Add', form.tentativeTag, onInput, onSubmit);
	});
var _user$project$Animals_Animal_EditableView$deleteTagControl = F2(
	function (displayed, form) {
		var onDelete = function (name) {
			return A2(
				_user$project$Animals_Msg$CheckFormChange,
				displayed,
				A2(
					_user$project$Animals_Animal_Lenses$form_tags.update,
					_elm_community$list_extra$List_Extra$remove(name),
					form));
		};
		return _user$project$Pile_Bulma$horizontalControls(
			A2(
				_elm_lang$core$List$map,
				_user$project$Pile_Bulma$deletableTag(onDelete),
				form.tags));
	});
var _user$project$Animals_Animal_EditableView$nameEditControl = F2(
	function (displayed, form) {
		return A2(
			_user$project$Pile_Bulma$soleTextInputInRow,
			form.name,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Events$onInput(
					A3(_user$project$Animals_Animal_Form$textFieldEditHandler, displayed, form, _user$project$Animals_Animal_Lenses$form_name)),
				_1: {ctor: '[]'}
			});
	});
var _user$project$Animals_Animal_EditableView$editableView = F4(
	function (displayed, form, makeSaveMsg, makeCancelMsg) {
		return A2(
			_user$project$Pile_Bulma$highlightedRow,
			{ctor: '[]'},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$td,
					{ctor: '[]'},
					{
						ctor: '::',
						_0: A2(
							_user$project$Pile_Bulma$controlRow,
							'Name',
							A2(_user$project$Animals_Animal_EditableView$nameEditControl, displayed, form)),
						_1: {
							ctor: '::',
							_0: A2(
								_user$project$Pile_Bulma$controlRow,
								'Tags',
								A2(_user$project$Animals_Animal_EditableView$deleteTagControl, displayed, form)),
							_1: {
								ctor: '::',
								_0: A2(
									_user$project$Pile_Bulma$controlRow,
									'New Tag',
									A2(_user$project$Animals_Animal_EditableView$newTagControl, displayed, form)),
								_1: {
									ctor: '::',
									_0: A2(
										_user$project$Pile_Bulma$leftwardSave,
										form.isValid,
										A2(makeSaveMsg, displayed, form)),
									_1: {
										ctor: '::',
										_0: A2(
											_user$project$Pile_Bulma$leftwardSave,
											form.isValid,
											A2(makeCancelMsg, displayed, form)),
										_1: {
											ctor: '::',
											_0: A2(
												_user$project$Animals_Animal_Flash$showWithButton,
												displayed.animalFlash,
												_user$project$Animals_Msg$RemoveFlash(displayed)),
											_1: {ctor: '[]'}
										}
									}
								}
							}
						}
					}),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$td,
						{ctor: '[]'},
						{ctor: '[]'}),
					_1: {
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$td,
							{ctor: '[]'},
							{ctor: '[]'}),
						_1: {
							ctor: '::',
							_0: _user$project$Animals_Animal_Icons$editHelp(_user$project$Pile_Bulma$tdIcon),
							_1: {ctor: '[]'}
						}
					}
				}
			});
	});

var _user$project$Animals_Pages_AllPage$filterHelp = function (iconType) {
	return A3(iconType, 'fa-question-circle', 'Help on filtering', _user$project$Animals_Msg$NoOp);
};
var _user$project$Animals_Pages_AllPage$calendarHelp = function (iconType) {
	return A3(iconType, 'fa-question-circle', 'Help on animals and dates', _user$project$Animals_Msg$NoOp);
};
var _user$project$Animals_Pages_AllPage$speciesFilter = function (model) {
	var textOption = F2(
		function (val, display) {
			return A2(
				_elm_lang$html$Html$option,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$value(val),
					_1: {
						ctor: '::',
						_0: _elm_lang$html$Html_Events$onClick(
							_user$project$Animals_Msg$SetSpeciesFilter(val)),
						_1: {ctor: '[]'}
					}
				},
				{
					ctor: '::',
					_0: _elm_lang$html$Html$text(display),
					_1: {ctor: '[]'}
				});
		});
	return _user$project$Pile_Bulma$centeredLevelItem(
		{
			ctor: '::',
			_0: _user$project$Pile_Bulma$headingP('Species'),
			_1: {
				ctor: '::',
				_0: _user$project$Pile_Bulma$simpleSelect(
					{
						ctor: '::',
						_0: A2(textOption, '', 'Any'),
						_1: {
							ctor: '::',
							_0: A2(textOption, 'bovine', 'bovine'),
							_1: {
								ctor: '::',
								_0: A2(textOption, 'equine', 'equine'),
								_1: {ctor: '[]'}
							}
						}
					}),
				_1: {ctor: '[]'}
			}
		});
};
var _user$project$Animals_Pages_AllPage$tagsFilter = function (model) {
	return _user$project$Pile_Bulma$centeredLevelItem(
		{
			ctor: '::',
			_0: _user$project$Pile_Bulma$headingP('Tag'),
			_1: {
				ctor: '::',
				_0: A2(_user$project$Pile_Bulma$simpleTextInput, model.tagFilter, _user$project$Animals_Msg$SetTagFilter),
				_1: {ctor: '[]'}
			}
		});
};
var _user$project$Animals_Pages_AllPage$nameFilter = function (model) {
	return _user$project$Pile_Bulma$centeredLevelItem(
		{
			ctor: '::',
			_0: _user$project$Pile_Bulma$headingP('Name'),
			_1: {
				ctor: '::',
				_0: A2(_user$project$Pile_Bulma$simpleTextInput, model.nameFilter, _user$project$Animals_Msg$SetNameFilter),
				_1: {ctor: '[]'}
			}
		});
};
var _user$project$Animals_Pages_AllPage$dateControl = F3(
	function (hasOpenPicker, displayString, calendarToggleMsg) {
		var iconF = function () {
			var _p0 = hasOpenPicker;
			if (_p0 === false) {
				return A2(_user$project$Pile_Bulma$plainIcon, 'fa-caret-down', 'Pick a date from a calendar');
			} else {
				return A2(_user$project$Pile_Bulma$plainIcon, 'fa-caret-up', 'Close the calendar');
			}
		}();
		return A2(
			_elm_lang$html$Html$p,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class('has-text-centered'),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: _elm_lang$html$Html$text(displayString),
				_1: {
					ctor: '::',
					_0: iconF(calendarToggleMsg),
					_1: {ctor: '[]'}
				}
			});
	});
var _user$project$Animals_Pages_AllPage$animalForm = F2(
	function (model, animal) {
		return A2(
			_elm_lang$core$Maybe$withDefault,
			_user$project$Animals_Animal_Form$nullForm,
			A2(_elm_lang$core$Dict$get, animal.id, model.forms));
	});
var _user$project$Animals_Pages_AllPage$individualAnimalView = F2(
	function (model, displayedAnimal) {
		var _p1 = displayedAnimal.format;
		switch (_p1.ctor) {
			case 'Compact':
				return _user$project$Animals_Animal_ReadOnlyViews$compactView(displayedAnimal);
			case 'Expanded':
				return _user$project$Animals_Animal_ReadOnlyViews$expandedView(displayedAnimal);
			default:
				return A4(
					_user$project$Animals_Animal_EditableView$editableView,
					displayedAnimal,
					A2(_user$project$Animals_Pages_AllPage$animalForm, model, displayedAnimal.animal),
					_user$project$Animals_Msg$StartSavingAnimalEdits,
					_user$project$Animals_Msg$StartSavingAnimalEdits);
		}
	});
var _user$project$Animals_Pages_AllPage$humanSorted = function (animals) {
	return A2(
		_elm_lang$core$List$sortBy,
		function (_p2) {
			return _elm_lang$core$String$toLower(
				function (_) {
					return _.name;
				}(
					function (_) {
						return _.animal;
					}(_p2)));
		},
		animals);
};
var _user$project$Animals_Pages_AllPage$aggregateFilter = F2(
	function (preds, animal) {
		aggregateFilter:
		while (true) {
			var _p3 = preds;
			if (_p3.ctor === '[]') {
				return true;
			} else {
				if (_p3._0(animal)) {
					var _v3 = _p3._1,
						_v4 = animal;
					preds = _v3;
					animal = _v4;
					continue aggregateFilter;
				} else {
					return false;
				}
			}
		}
	});
var _user$project$Animals_Pages_AllPage$applyFilters = F2(
	function (model, animals) {
		var hasWanted = F2(
			function (modelFilter, animalValue) {
				var has = _elm_lang$core$String$toLower(animalValue);
				var wanted = _elm_lang$core$String$toLower(
					modelFilter(model));
				return A2(_elm_lang$core$String$startsWith, wanted, has);
			});
		var rightSpecies = function (displayed) {
			return A2(
				hasWanted,
				function (_) {
					return _.speciesFilter;
				},
				displayed.animal.species);
		};
		var rightName = function (displayed) {
			return A2(
				hasWanted,
				function (_) {
					return _.nameFilter;
				},
				displayed.animal.name);
		};
		var rightTag = function (displayed) {
			return _elm_lang$core$String$isEmpty(model.tagFilter) || A2(
				_elm_lang$core$List$any,
				hasWanted(
					function (_) {
						return _.tagFilter;
					}),
				displayed.animal.tags);
		};
		return _user$project$Animals_Pages_AllPage$humanSorted(
			A2(
				_elm_lang$core$List$filter,
				_user$project$Animals_Pages_AllPage$aggregateFilter(
					{
						ctor: '::',
						_0: rightSpecies,
						_1: {
							ctor: '::',
							_0: rightName,
							_1: {
								ctor: '::',
								_0: rightTag,
								_1: {ctor: '[]'}
							}
						}
					}),
				animals));
	});
var _user$project$Animals_Pages_AllPage$allPageAnimals = function (model) {
	return A2(
		_elm_lang$core$List$filterMap,
		_elm_lang$core$Basics$identity,
		A2(
			_elm_lang$core$List$map,
			function (animal) {
				return A2(_elm_lang$core$Dict$get, animal, model.animals);
			},
			_elm_lang$core$Set$toList(model.allPageAnimals)));
};
var _user$project$Animals_Pages_AllPage$filterView = function (model) {
	return _user$project$Pile_Bulma$centeredColumns(
		{
			ctor: '::',
			_0: A2(
				_user$project$Pile_Bulma$column,
				3,
				{
					ctor: '::',
					_0: A2(
						_user$project$Pile_Bulma$messageView,
						{
							ctor: '::',
							_0: _elm_lang$html$Html$text('Animals as of...'),
							_1: {
								ctor: '::',
								_0: _user$project$Animals_Pages_AllPage$calendarHelp(_user$project$Pile_Bulma$rightIcon),
								_1: {ctor: '[]'}
							}
						},
						{
							ctor: '::',
							_0: A4(_user$project$Pile_Calendar$view, _user$project$Animals_Pages_AllPage$dateControl, _user$project$Animals_Msg$ToggleDatePicker, _user$project$Animals_Msg$SelectDate, model),
							_1: {ctor: '[]'}
						}),
					_1: {ctor: '[]'}
				}),
			_1: {
				ctor: '::',
				_0: A2(
					_user$project$Pile_Bulma$column,
					8,
					{
						ctor: '::',
						_0: A2(
							_user$project$Pile_Bulma$messageView,
							{
								ctor: '::',
								_0: _elm_lang$html$Html$text('Filter by...'),
								_1: {
									ctor: '::',
									_0: _user$project$Animals_Pages_AllPage$filterHelp(_user$project$Pile_Bulma$rightIcon),
									_1: {ctor: '[]'}
								}
							},
							{
								ctor: '::',
								_0: _user$project$Pile_Bulma$distributeHorizontally(
									{
										ctor: '::',
										_0: _user$project$Animals_Pages_AllPage$nameFilter(model),
										_1: {
											ctor: '::',
											_0: _user$project$Animals_Pages_AllPage$speciesFilter(model),
											_1: {
												ctor: '::',
												_0: _user$project$Animals_Pages_AllPage$tagsFilter(model),
												_1: {ctor: '[]'}
											}
										}
									}),
								_1: {ctor: '[]'}
							}),
						_1: {ctor: '[]'}
					}),
				_1: {ctor: '[]'}
			}
		});
};
var _user$project$Animals_Pages_AllPage$animalViews = function (model) {
	return A2(
		_elm_lang$core$List$map,
		_user$project$Animals_Pages_AllPage$individualAnimalView(model),
		A2(
			_user$project$Animals_Pages_AllPage$applyFilters,
			model,
			_user$project$Animals_Pages_AllPage$allPageAnimals(model)));
};
var _user$project$Animals_Pages_AllPage$view = function (model) {
	return A2(
		_elm_lang$html$Html$div,
		{ctor: '[]'},
		{
			ctor: '::',
			_0: _user$project$Animals_Pages_AllPage$filterView(model),
			_1: {
				ctor: '::',
				_0: _user$project$Animals_Pages_PageFlash$show(model.pageFlash),
				_1: {
					ctor: '::',
					_0: _user$project$Pile_Bulma$headerlessTable(
						_user$project$Animals_Pages_AllPage$animalViews(model)),
					_1: {ctor: '[]'}
				}
			}
		});
};

var _user$project$Animals_Pages_AddPage$view = function (model) {
	return A2(
		_elm_lang$html$Html$div,
		{ctor: '[]'},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$nav,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('level is-mobile'),
					_1: {ctor: '[]'}
				},
				{
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$div,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class('level-left'),
							_1: {ctor: '[]'}
						},
						{
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$p,
								{
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$class('level-item'),
									_1: {ctor: '[]'}
								},
								{
									ctor: '::',
									_0: _elm_lang$html$Html$text('Create'),
									_1: {ctor: '[]'}
								}),
							_1: {
								ctor: '::',
								_0: A2(
									_elm_lang$html$Html$p,
									{
										ctor: '::',
										_0: _elm_lang$html$Html_Attributes$class('level-item'),
										_1: {ctor: '[]'}
									},
									{
										ctor: '::',
										_0: A2(
											_elm_lang$html$Html$input,
											{
												ctor: '::',
												_0: _elm_lang$html$Html_Attributes$class('input'),
												_1: {
													ctor: '::',
													_0: _elm_lang$html$Html_Attributes$type_('text'),
													_1: {
														ctor: '::',
														_0: _elm_lang$html$Html_Attributes$value('1'),
														_1: {
															ctor: '::',
															_0: _elm_lang$html$Html_Attributes$disabled(true),
															_1: {
																ctor: '::',
																_0: _elm_lang$html$Html_Attributes$style(
																	{
																		ctor: '::',
																		_0: {ctor: '_Tuple2', _0: 'width', _1: '3em'},
																		_1: {ctor: '[]'}
																	}),
																_1: {ctor: '[]'}
															}
														}
													}
												}
											},
											{ctor: '[]'}),
										_1: {ctor: '[]'}
									}),
								_1: {
									ctor: '::',
									_0: A2(
										_elm_lang$html$Html$p,
										{
											ctor: '::',
											_0: _elm_lang$html$Html_Attributes$class('level-item'),
											_1: {ctor: '[]'}
										},
										{
											ctor: '::',
											_0: _elm_lang$html$Html$text('new'),
											_1: {ctor: '[]'}
										}),
									_1: {
										ctor: '::',
										_0: A2(
											_elm_lang$html$Html$p,
											{
												ctor: '::',
												_0: _elm_lang$html$Html_Attributes$class('level-item'),
												_1: {ctor: '[]'}
											},
											{
												ctor: '::',
												_0: _user$project$Pile_Bulma$disabledSelect(
													{
														ctor: '::',
														_0: A2(
															_elm_lang$html$Html$option,
															{
																ctor: '::',
																_0: _elm_lang$html$Html_Attributes$value('bovine'),
																_1: {ctor: '[]'}
															},
															{
																ctor: '::',
																_0: _elm_lang$html$Html$text('bovine'),
																_1: {ctor: '[]'}
															}),
														_1: {
															ctor: '::',
															_0: A2(
																_elm_lang$html$Html$option,
																{
																	ctor: '::',
																	_0: _elm_lang$html$Html_Attributes$value('equine'),
																	_1: {ctor: '[]'}
																},
																{
																	ctor: '::',
																	_0: _elm_lang$html$Html$text('equine'),
																	_1: {ctor: '[]'}
																}),
															_1: {ctor: '[]'}
														}
													}),
												_1: {ctor: '[]'}
											}),
										_1: {
											ctor: '::',
											_0: A2(
												_elm_lang$html$Html$p,
												{
													ctor: '::',
													_0: _elm_lang$html$Html_Attributes$class('level-item'),
													_1: {ctor: '[]'}
												},
												{
													ctor: '::',
													_0: _elm_lang$html$Html$text('animal to edit'),
													_1: {ctor: '[]'}
												}),
											_1: {
												ctor: '::',
												_0: A2(
													_elm_lang$html$Html$p,
													{
														ctor: '::',
														_0: _elm_lang$html$Html_Attributes$class('level-item'),
														_1: {ctor: '[]'}
													},
													{
														ctor: '::',
														_0: A2(
															_elm_lang$html$Html$a,
															{
																ctor: '::',
																_0: _elm_lang$html$Html_Attributes$class('button is-primary'),
																_1: {
																	ctor: '::',
																	_0: _elm_lang$html$Html_Attributes$href('#'),
																	_1: {
																		ctor: '::',
																		_0: _user$project$Pile_HtmlShorthand$onClickWithoutPropagation(
																			A2(_user$project$Animals_Msg$AddNewAnimals, 1, 'bovine')),
																		_1: {ctor: '[]'}
																	}
																}
															},
															{
																ctor: '::',
																_0: _elm_lang$html$Html$text('Now'),
																_1: {ctor: '[]'}
															}),
														_1: {ctor: '[]'}
													}),
												_1: {ctor: '[]'}
											}
										}
									}
								}
							}
						}),
					_1: {ctor: '[]'}
				}),
			_1: {
				ctor: '::',
				_0: _user$project$Animals_Pages_PageFlash$show(model.pageFlash),
				_1: {ctor: '[]'}
			}
		});
};

var _user$project$Animals_Pages_HelpPage$view = function (model) {
	return A2(_user$project$Pile_Bulma$infoMessage, 'Unfinished', 'The help page hasn\'t been written yet.');
};

var _user$project$Animals_View$view = function (model) {
	return A2(
		_elm_lang$html$Html$div,
		{ctor: '[]'},
		{
			ctor: '::',
			_0: A2(
				_user$project$Pile_Bulma$tabs,
				model.page,
				{
					ctor: '::',
					_0: {
						ctor: '_Tuple3',
						_0: _user$project$Animals_Pages_Declare$AllPage,
						_1: 'View Animals',
						_2: _user$project$Animals_Msg$StartPageChange(_user$project$Animals_Pages_Declare$AllPage)
					},
					_1: {
						ctor: '::',
						_0: {
							ctor: '_Tuple3',
							_0: _user$project$Animals_Pages_Declare$AddPage,
							_1: 'Add Animals',
							_2: _user$project$Animals_Msg$StartPageChange(_user$project$Animals_Pages_Declare$AddPage)
						},
						_1: {
							ctor: '::',
							_0: {
								ctor: '_Tuple3',
								_0: _user$project$Animals_Pages_Declare$HelpPage,
								_1: 'Help',
								_2: _user$project$Animals_Msg$StartPageChange(_user$project$Animals_Pages_Declare$HelpPage)
							},
							_1: {ctor: '[]'}
						}
					}
				}),
			_1: {
				ctor: '::',
				_0: function () {
					var _p0 = model.page;
					switch (_p0.ctor) {
						case 'AllPage':
							return _user$project$Animals_Pages_AllPage$view(model);
						case 'AddPage':
							return _user$project$Animals_Pages_AddPage$view(model);
						default:
							return _user$project$Animals_Pages_HelpPage$view(model);
					}
				}(),
				_1: {ctor: '[]'}
			}
		});
};

var _user$project$Animals$main = A2(
	_elm_lang$navigation$Navigation$programWithFlags,
	_user$project$Animals_Msg$NoticePageChange,
	{init: _user$project$Animals_Main$init, view: _user$project$Animals_View$view, update: _user$project$Animals_Main$update, subscriptions: _user$project$Animals_Main$subscriptions})(
	A2(
		_elm_lang$core$Json_Decode$andThen,
		function (csrfToken) {
			return _elm_lang$core$Json_Decode$succeed(
				{csrfToken: csrfToken});
		},
		A2(_elm_lang$core$Json_Decode$field, 'csrfToken', _elm_lang$core$Json_Decode$string)));

var _user$project$IV_Pile_CmdFlow$set = F3(
	function (lens, newPart, _p0) {
		var _p1 = _p0;
		return {
			ctor: '_Tuple2',
			_0: A2(lens.set, newPart, _p1._0),
			_1: _p1._1
		};
	});
var _user$project$IV_Pile_CmdFlow$update = F3(
	function (lens, f, _p2) {
		var _p3 = _p2;
		var _p5 = _p3._0;
		var _p4 = f(
			lens.get(_p5));
		var newPart = _p4._0;
		var newCmd = _p4._1;
		return {
			ctor: '_Tuple2',
			_0: A2(lens.set, newPart, _p5),
			_1: _elm_lang$core$Platform_Cmd$batch(
				{
					ctor: '::',
					_0: _p3._1,
					_1: {
						ctor: '::',
						_0: newCmd,
						_1: {ctor: '[]'}
					}
				})
		};
	});
var _user$project$IV_Pile_CmdFlow$flow = function (model) {
	return {ctor: '_Tuple2', _0: model, _1: _elm_lang$core$Platform_Cmd$none};
};

var _user$project$IV_Lenses$model_apparatus = function () {
	var set = F2(
		function (new2, arg1) {
			return _elm_lang$core$Native_Utils.update(
				arg1,
				{apparatus: new2});
		});
	var get = function (arg1) {
		return arg1.apparatus;
	};
	return A2(_arturopala$elm_monocle$Monocle_Lens$Lens, get, set);
}();
var _user$project$IV_Lenses$model_clock = function () {
	var set = F2(
		function (new2, arg1) {
			return _elm_lang$core$Native_Utils.update(
				arg1,
				{clock: new2});
		});
	var get = function (arg1) {
		return arg1.clock;
	};
	return A2(_arturopala$elm_monocle$Monocle_Lens$Lens, get, set);
}();
var _user$project$IV_Lenses$model_scenario = function () {
	var set = F2(
		function (new2, arg1) {
			return _elm_lang$core$Native_Utils.update(
				arg1,
				{scenario: new2});
		});
	var get = function (arg1) {
		return arg1.scenario;
	};
	return A2(_arturopala$elm_monocle$Monocle_Lens$Lens, get, set);
}();
var _user$project$IV_Lenses$model_page = function () {
	var set = F2(
		function (new2, arg1) {
			return _elm_lang$core$Native_Utils.update(
				arg1,
				{page: new2});
		});
	var get = function (arg1) {
		return arg1.page;
	};
	return A2(_arturopala$elm_monocle$Monocle_Lens$Lens, get, set);
}();
var _user$project$IV_Lenses$setPage = function (newVal) {
	return A2(_user$project$IV_Pile_CmdFlow$set, _user$project$IV_Lenses$model_page, newVal);
};
var _user$project$IV_Lenses$updateClock = function (pairProducingF) {
	return A2(_user$project$IV_Pile_CmdFlow$update, _user$project$IV_Lenses$model_clock, pairProducingF);
};
var _user$project$IV_Lenses$updateApparatus = function (pairProducingF) {
	return A2(_user$project$IV_Pile_CmdFlow$update, _user$project$IV_Lenses$model_apparatus, pairProducingF);
};
var _user$project$IV_Lenses$updateScenario = function (pairProducingF) {
	return A2(_user$project$IV_Pile_CmdFlow$update, _user$project$IV_Lenses$model_scenario, pairProducingF);
};
var _user$project$IV_Lenses$flow = _user$project$IV_Pile_CmdFlow$flow;

var _user$project$IV_Scenario_Msg$ChangedDropsPerMil = function (a) {
	return {ctor: 'ChangedDropsPerMil', _0: a};
};
var _user$project$IV_Scenario_Msg$ChangedBagContents = function (a) {
	return {ctor: 'ChangedBagContents', _0: a};
};
var _user$project$IV_Scenario_Msg$ChangedBagCapacity = function (a) {
	return {ctor: 'ChangedBagCapacity', _0: a};
};
var _user$project$IV_Scenario_Msg$ChangedMinutesText = function (a) {
	return {ctor: 'ChangedMinutesText', _0: a};
};
var _user$project$IV_Scenario_Msg$ChangedHoursText = function (a) {
	return {ctor: 'ChangedHoursText', _0: a};
};
var _user$project$IV_Scenario_Msg$ChangedDripText = function (a) {
	return {ctor: 'ChangedDripText', _0: a};
};

var _user$project$IV_Types$asDuration = function (_p0) {
	var _p1 = _p0;
	var _p2 = _p1._0;
	return _elm_lang$core$Native_Utils.eq(_p2, 0.0) ? (10000.0 * _elm_lang$core$Time$second) : ((1 / _p2) * _elm_lang$core$Time$second);
};
var _user$project$IV_Types$DropsPerSecond = function (a) {
	return {ctor: 'DropsPerSecond', _0: a};
};
var _user$project$IV_Types$Level = function (a) {
	return {ctor: 'Level', _0: a};
};
var _user$project$IV_Types$Hours = function (a) {
	return {ctor: 'Hours', _0: a};
};
var _user$project$IV_Types$PartlyEmptied = F2(
	function (a, b) {
		return {ctor: 'PartlyEmptied', _0: a, _1: b};
	});
var _user$project$IV_Types$FullyEmptied = function (a) {
	return {ctor: 'FullyEmptied', _0: a};
};
var _user$project$IV_Types$AboutPage = {ctor: 'AboutPage'};
var _user$project$IV_Types$MainPage = {ctor: 'MainPage'};

var _user$project$IV_Scenario_Model$emptyBackground = {tag: 'Write your own', bagCapacityInLiters: '0', bagContentsInLiters: '0', bagType: 'container', dropsPerMil: '15.0', animalDescription: 'a case'};
var _user$project$IV_Scenario_Model$cowBackground = _elm_lang$core$Native_Utils.update(
	_user$project$IV_Scenario_Model$emptyBackground,
	{tag: '1560 lb. cow', animalDescription: 'a 1560 lb 3d lactation purebred Holstein', bagCapacityInLiters: '20', bagContentsInLiters: '19', bagType: '5-gallon carboy'});
var _user$project$IV_Scenario_Model$calfBackground = _elm_lang$core$Native_Utils.update(
	_user$project$IV_Scenario_Model$emptyBackground,
	{tag: '90 lb. heifer calf', animalDescription: 'a 90 lb. 10-day-old Hereford heifer calf', bagCapacityInLiters: '2', bagContentsInLiters: '2', bagType: 'bag'});
var _user$project$IV_Scenario_Model$emptyDecisions = {dripRate: '0', simulationHours: '0', simulationMinutes: '0'};
var _user$project$IV_Scenario_Model$scenario = F2(
	function (background, decisions) {
		return {background: background, caseBackgroundEditorOpen: false, decisions: decisions};
	});
var _user$project$IV_Scenario_Model$preparedScenario = function (background) {
	return A2(_user$project$IV_Scenario_Model$scenario, background, _user$project$IV_Scenario_Model$emptyDecisions);
};
var _user$project$IV_Scenario_Model$withEmptiedDecisions = function (editableModel) {
	return _user$project$IV_Scenario_Model$preparedScenario(editableModel.background);
};
var _user$project$IV_Scenario_Model$EditableModel = F3(
	function (a, b, c) {
		return {background: a, caseBackgroundEditorOpen: b, decisions: c};
	});
var _user$project$IV_Scenario_Model$CaseBackground = F6(
	function (a, b, c, d, e, f) {
		return {tag: a, bagCapacityInLiters: b, bagContentsInLiters: c, bagType: d, dropsPerMil: e, animalDescription: f};
	});
var _user$project$IV_Scenario_Model$TreatmentDecisions = F3(
	function (a, b, c) {
		return {dripRate: a, simulationHours: b, simulationMinutes: c};
	});

var _user$project$IV_Pile_ManagedStrings$isValidIntString = function (string) {
	if (_elm_lang$core$String$isEmpty(string)) {
		return true;
	} else {
		var _p0 = _elm_lang$core$String$toInt(string);
		if (_p0.ctor === 'Ok') {
			return true;
		} else {
			return false;
		}
	}
};
var _user$project$IV_Pile_ManagedStrings$floatString = function (string) {
	if (_elm_lang$core$String$isEmpty(string)) {
		return 0.0;
	} else {
		var _p1 = _elm_lang$core$String$toFloat(string);
		if (_p1.ctor === 'Ok') {
			return _p1._0;
		} else {
			return 1.0e9;
		}
	}
};
var _user$project$IV_Pile_ManagedStrings$isValidFloatString = function (string) {
	if (_elm_lang$core$String$isEmpty(string)) {
		return true;
	} else {
		var _p2 = _elm_lang$core$String$toFloat(string);
		if (_p2.ctor === 'Ok') {
			return true;
		} else {
			return false;
		}
	}
};

var _user$project$IV_Scenario_DataExport$litersPerHour = function (floats) {
	var milsPerSecond = floats.dripRate / floats.dropsPerMil;
	var milsPerHour = (milsPerSecond * 60) * 60;
	return milsPerHour / 1000;
};
var _user$project$IV_Scenario_DataExport$hoursToEmptyBag = function (floats) {
	return floats.bagContentsInLiters / _user$project$IV_Scenario_DataExport$litersPerHour(floats);
};
var _user$project$IV_Scenario_DataExport$hours = function (floats) {
	var m = floats.simulationMinutes;
	var h = floats.simulationHours;
	return h + (m / 60.0);
};
var _user$project$IV_Scenario_DataExport$endingFractionBagFilled = function (floats) {
	var litersGone = _user$project$IV_Scenario_DataExport$litersPerHour(floats) * _user$project$IV_Scenario_DataExport$hours(floats);
	return (floats.bagContentsInLiters - litersGone) / floats.bagCapacityInLiters;
};
var _user$project$IV_Scenario_DataExport$drainage = function (floats) {
	var planned = _user$project$IV_Scenario_DataExport$hours(floats);
	var toEmpty = _user$project$IV_Scenario_DataExport$hoursToEmptyBag(floats);
	return (_elm_lang$core$Native_Utils.cmp(planned, toEmpty) < 0) ? A2(
		_user$project$IV_Types$PartlyEmptied,
		_user$project$IV_Types$Hours(planned),
		_user$project$IV_Types$Level(
			_user$project$IV_Scenario_DataExport$endingFractionBagFilled(floats))) : _user$project$IV_Types$FullyEmptied(
		_user$project$IV_Types$Hours(toEmpty));
};
var _user$project$IV_Scenario_DataExport$toFloats = function (stringContainer) {
	return {
		bagCapacityInLiters: _user$project$IV_Pile_ManagedStrings$floatString(stringContainer.background.bagCapacityInLiters),
		bagContentsInLiters: _user$project$IV_Pile_ManagedStrings$floatString(stringContainer.background.bagContentsInLiters),
		dropsPerMil: _user$project$IV_Pile_ManagedStrings$floatString(stringContainer.background.dropsPerMil),
		dripRate: _user$project$IV_Pile_ManagedStrings$floatString(stringContainer.decisions.dripRate),
		simulationHours: _user$project$IV_Pile_ManagedStrings$floatString(stringContainer.decisions.simulationHours),
		simulationMinutes: _user$project$IV_Pile_ManagedStrings$floatString(stringContainer.decisions.simulationMinutes)
	};
};
var _user$project$IV_Scenario_DataExport$startingLevel = function (editableModel) {
	var floats = _user$project$IV_Scenario_DataExport$toFloats(editableModel);
	return _user$project$IV_Types$Level(floats.bagContentsInLiters / floats.bagCapacityInLiters);
};
var _user$project$IV_Scenario_DataExport$dripRate = function (editableModel) {
	return _user$project$IV_Types$DropsPerSecond(
		_user$project$IV_Pile_ManagedStrings$floatString(editableModel.decisions.dripRate));
};
var _user$project$IV_Scenario_DataExport$runnableModel = function (editableModel) {
	var floats = _user$project$IV_Scenario_DataExport$toFloats(editableModel);
	return {
		totalHours: _user$project$IV_Types$Hours(
			_user$project$IV_Scenario_DataExport$hours(floats)),
		drainage: _user$project$IV_Scenario_DataExport$drainage(floats)
	};
};
var _user$project$IV_Scenario_DataExport$SimulationData = F2(
	function (a, b) {
		return {totalHours: a, drainage: b};
	});
var _user$project$IV_Scenario_DataExport$DataAsFloats = F6(
	function (a, b, c, d, e, f) {
		return {bagCapacityInLiters: a, bagContentsInLiters: b, dropsPerMil: c, dripRate: d, simulationHours: e, simulationMinutes: f};
	});

var _user$project$IV_Msg$StartPageChange = function (a) {
	return {ctor: 'StartPageChange', _0: a};
};
var _user$project$IV_Msg$NoticePageChange = function (a) {
	return {ctor: 'NoticePageChange', _0: a};
};
var _user$project$IV_Msg$CloseCaseBackgroundEditor = {ctor: 'CloseCaseBackgroundEditor'};
var _user$project$IV_Msg$OpenCaseBackgroundEditor = {ctor: 'OpenCaseBackgroundEditor'};
var _user$project$IV_Msg$ToScenario = function (a) {
	return {ctor: 'ToScenario', _0: a};
};
var _user$project$IV_Msg$AnimationClockTick = function (a) {
	return {ctor: 'AnimationClockTick', _0: a};
};
var _user$project$IV_Msg$RestartScenario = {ctor: 'RestartScenario'};
var _user$project$IV_Msg$PickedScenario = function (a) {
	return {ctor: 'PickedScenario', _0: a};
};
var _user$project$IV_Msg$ChamberEmptied = {ctor: 'ChamberEmptied'};
var _user$project$IV_Msg$FluidRanOut = {ctor: 'FluidRanOut'};
var _user$project$IV_Msg$ChoseDripRate = function (a) {
	return {ctor: 'ChoseDripRate', _0: a};
};
var _user$project$IV_Msg$StopSimulation = {ctor: 'StopSimulation'};
var _user$project$IV_Msg$StartSimulation = function (a) {
	return {ctor: 'StartSimulation', _0: a};
};

var _user$project$IV_Pile_Animation$linearEasing = function (duration) {
	return _mdgriffith$elm_style_animation$Animation$easing(
		{ease: _elm_lang$core$Basics$identity, duration: duration});
};
var _user$project$IV_Pile_Animation$simulationDuration = function (_p0) {
	var _p1 = _p0;
	return (_p1._0 * 1.5) * _elm_lang$core$Time$second;
};
var _user$project$IV_Pile_Animation$easeForHours = function (hours) {
	return _user$project$IV_Pile_Animation$linearEasing(
		_user$project$IV_Pile_Animation$simulationDuration(hours));
};

var _user$project$IV_Pile_SvgAttributes$pointFmt = A2(
	_krisajenkins$formatting$Formatting_ops['<>'],
	_krisajenkins$formatting$Formatting$float,
	A2(
		_krisajenkins$formatting$Formatting_ops['<>'],
		_krisajenkins$formatting$Formatting$s(','),
		_krisajenkins$formatting$Formatting$float));
var _user$project$IV_Pile_SvgAttributes$translateFmt = A2(
	_krisajenkins$formatting$Formatting_ops['<>'],
	_krisajenkins$formatting$Formatting$s('translate('),
	A2(
		_krisajenkins$formatting$Formatting_ops['<>'],
		_user$project$IV_Pile_SvgAttributes$pointFmt,
		_krisajenkins$formatting$Formatting$s(')')));
var _user$project$IV_Pile_SvgAttributes$translate = function (_p0) {
	var _p1 = _p0;
	return A3(_krisajenkins$formatting$Formatting$print, _user$project$IV_Pile_SvgAttributes$translateFmt, _p1._0, _p1._1);
};
var _user$project$IV_Pile_SvgAttributes$toSvgPoint = function (_p2) {
	var _p3 = _p2;
	return A3(_krisajenkins$formatting$Formatting$print, _user$project$IV_Pile_SvgAttributes$pointFmt, _p3._0, _p3._1);
};
var _user$project$IV_Pile_SvgAttributes$toSvgPoints = function (points) {
	return A2(
		_elm_lang$core$String$join,
		' ',
		A2(_elm_lang$core$List$map, _user$project$IV_Pile_SvgAttributes$toSvgPoint, points));
};
var _user$project$IV_Pile_SvgAttributes$useInt = F2(
	function (stringFn, i) {
		return stringFn(
			A2(_krisajenkins$formatting$Formatting$print, _krisajenkins$formatting$Formatting$int, i));
	});
var _user$project$IV_Pile_SvgAttributes$markerWidth_ = _user$project$IV_Pile_SvgAttributes$useInt(_elm_lang$svg$Svg_Attributes$markerWidth);
var _user$project$IV_Pile_SvgAttributes$markerHeight_ = _user$project$IV_Pile_SvgAttributes$useInt(_elm_lang$svg$Svg_Attributes$markerHeight);
var _user$project$IV_Pile_SvgAttributes$x_ = _user$project$IV_Pile_SvgAttributes$useInt(_elm_lang$svg$Svg_Attributes$x);
var _user$project$IV_Pile_SvgAttributes$x1_ = _user$project$IV_Pile_SvgAttributes$useInt(_elm_lang$svg$Svg_Attributes$x1);
var _user$project$IV_Pile_SvgAttributes$x2_ = _user$project$IV_Pile_SvgAttributes$useInt(_elm_lang$svg$Svg_Attributes$x2);
var _user$project$IV_Pile_SvgAttributes$y_ = _user$project$IV_Pile_SvgAttributes$useInt(_elm_lang$svg$Svg_Attributes$y);
var _user$project$IV_Pile_SvgAttributes$y1_ = _user$project$IV_Pile_SvgAttributes$useInt(_elm_lang$svg$Svg_Attributes$y1);
var _user$project$IV_Pile_SvgAttributes$y2_ = _user$project$IV_Pile_SvgAttributes$useInt(_elm_lang$svg$Svg_Attributes$y2);
var _user$project$IV_Pile_SvgAttributes$cx_ = _user$project$IV_Pile_SvgAttributes$useInt(_elm_lang$svg$Svg_Attributes$cx);
var _user$project$IV_Pile_SvgAttributes$cy_ = _user$project$IV_Pile_SvgAttributes$useInt(_elm_lang$svg$Svg_Attributes$cy);
var _user$project$IV_Pile_SvgAttributes$r_ = _user$project$IV_Pile_SvgAttributes$useInt(_elm_lang$svg$Svg_Attributes$r);
var _user$project$IV_Pile_SvgAttributes$height_ = _user$project$IV_Pile_SvgAttributes$useInt(_elm_lang$svg$Svg_Attributes$height);
var _user$project$IV_Pile_SvgAttributes$width_ = _user$project$IV_Pile_SvgAttributes$useInt(_elm_lang$svg$Svg_Attributes$width);

var _user$project$IV_Apparatus_DrainingRectangle$animatableAttributes = F2(
	function (configuration, _p0) {
		var _p1 = _p0;
		var height = _p1._0 * _elm_lang$core$Basics$toFloat(configuration.containerHeight);
		var y = _elm_lang$core$Basics$toFloat(configuration.containerHeight) - height;
		return {
			ctor: '::',
			_0: _mdgriffith$elm_style_animation$Animation$y(y),
			_1: {
				ctor: '::',
				_0: _mdgriffith$elm_style_animation$Animation$height(
					_mdgriffith$elm_style_animation$Animation$px(height)),
				_1: {ctor: '[]'}
			}
		};
	});
var _user$project$IV_Apparatus_DrainingRectangle$fixedAttributes = function (configuration) {
	return {
		ctor: '::',
		_0: _elm_lang$svg$Svg_Attributes$fill(configuration.fillColor),
		_1: {
			ctor: '::',
			_0: _user$project$IV_Pile_SvgAttributes$x_(0),
			_1: {
				ctor: '::',
				_0: _user$project$IV_Pile_SvgAttributes$width_(configuration.containerWidth),
				_1: {ctor: '[]'}
			}
		}
	};
};
var _user$project$IV_Apparatus_DrainingRectangle$fluid = F2(
	function (chamberFluid, configuration) {
		return A2(
			_elm_lang$svg$Svg$rect,
			A2(
				_elm_lang$core$Basics_ops['++'],
				_mdgriffith$elm_style_animation$Animation$render(chamberFluid),
				_user$project$IV_Apparatus_DrainingRectangle$fixedAttributes(configuration)),
			{ctor: '[]'});
	});
var _user$project$IV_Apparatus_DrainingRectangle$container = function (configuration) {
	return A2(
		_elm_lang$svg$Svg$rect,
		{
			ctor: '::',
			_0: _elm_lang$svg$Svg_Attributes$fill('none'),
			_1: {
				ctor: '::',
				_0: _elm_lang$svg$Svg_Attributes$stroke('black'),
				_1: {
					ctor: '::',
					_0: _user$project$IV_Pile_SvgAttributes$x_(0),
					_1: {
						ctor: '::',
						_0: _user$project$IV_Pile_SvgAttributes$y_(0),
						_1: {
							ctor: '::',
							_0: _user$project$IV_Pile_SvgAttributes$width_(configuration.containerWidth),
							_1: {
								ctor: '::',
								_0: _user$project$IV_Pile_SvgAttributes$height_(configuration.containerHeight),
								_1: {ctor: '[]'}
							}
						}
					}
				}
			}
		},
		{ctor: '[]'});
};
var _user$project$IV_Apparatus_DrainingRectangle$doDrain = F5(
	function (configuration, hours, level, animationState, moreSteps) {
		var drainStep = A2(
			_mdgriffith$elm_style_animation$Animation$toWith,
			_user$project$IV_Pile_Animation$easeForHours(hours),
			A2(_user$project$IV_Apparatus_DrainingRectangle$animatableAttributes, configuration, level));
		return {
			ctor: '_Tuple2',
			_0: A2(
				_mdgriffith$elm_style_animation$Animation$interrupt,
				{ctor: '::', _0: drainStep, _1: moreSteps},
				animationState),
			_1: _elm_lang$core$Platform_Cmd$none
		};
	});
var _user$project$IV_Apparatus_DrainingRectangle$continueDraining = F2(
	function (tick, animationState) {
		return A2(_mdgriffith$elm_style_animation$Animation_Messenger$update, tick, animationState);
	});
var _user$project$IV_Apparatus_DrainingRectangle$drainThenSend = F4(
	function (configuration, hours, animationState, msg) {
		return A5(
			_user$project$IV_Apparatus_DrainingRectangle$doDrain,
			configuration,
			hours,
			_user$project$IV_Types$Level(0),
			animationState,
			{
				ctor: '::',
				_0: _mdgriffith$elm_style_animation$Animation_Messenger$send(msg),
				_1: {ctor: '[]'}
			});
	});
var _user$project$IV_Apparatus_DrainingRectangle$drainPartially = F4(
	function (configuration, hours, level, animationState) {
		return A5(
			_user$project$IV_Apparatus_DrainingRectangle$doDrain,
			configuration,
			hours,
			level,
			animationState,
			{ctor: '[]'});
	});
var _user$project$IV_Apparatus_DrainingRectangle$drain = F3(
	function (configuration, hours, animationState) {
		return A5(
			_user$project$IV_Apparatus_DrainingRectangle$doDrain,
			configuration,
			hours,
			_user$project$IV_Types$Level(0),
			animationState,
			{ctor: '[]'});
	});
var _user$project$IV_Apparatus_DrainingRectangle$render = F3(
	function (configuration, origin, animationState) {
		return A2(
			_elm_lang$svg$Svg$g,
			{
				ctor: '::',
				_0: _elm_lang$svg$Svg_Attributes$transform(
					_user$project$IV_Pile_SvgAttributes$translate(origin)),
				_1: {ctor: '[]'}
			},
			A2(
				_elm_lang$core$Basics_ops['++'],
				{
					ctor: '::',
					_0: A2(_user$project$IV_Apparatus_DrainingRectangle$fluid, animationState, configuration),
					_1: {
						ctor: '::',
						_0: _user$project$IV_Apparatus_DrainingRectangle$container(configuration),
						_1: {ctor: '[]'}
					}
				},
				configuration.extraFigures));
	});
var _user$project$IV_Apparatus_DrainingRectangle$startingState = F2(
	function (configuration, startingLevel) {
		return _mdgriffith$elm_style_animation$Animation$style(
			A2(_user$project$IV_Apparatus_DrainingRectangle$animatableAttributes, configuration, startingLevel));
	});
var _user$project$IV_Apparatus_DrainingRectangle$Configuration = F4(
	function (a, b, c, d) {
		return {containerWidth: a, containerHeight: b, fillColor: c, extraFigures: d};
	});

var _user$project$IV_Apparatus_ViewConstants$whiteColor = A3(_elm_lang$core$Color$rgb, 255, 255, 255);
var _user$project$IV_Apparatus_ViewConstants$variantFluidColor = A3(_elm_lang$core$Color$rgb, 193, 193, 193);
var _user$project$IV_Apparatus_ViewConstants$fluidColorString = '#d3d7cf';
var _user$project$IV_Apparatus_ViewConstants$fluidColor = A3(_elm_lang$core$Color$rgb, 211, 215, 207);
var _user$project$IV_Apparatus_ViewConstants$hoseHeight = 90;
var _user$project$IV_Apparatus_ViewConstants$dropHeight = 10;
var _user$project$IV_Apparatus_ViewConstants$dropWidth = 10;
var _user$project$IV_Apparatus_ViewConstants$hoseWidth = _user$project$IV_Apparatus_ViewConstants$dropWidth;
var _user$project$IV_Apparatus_ViewConstants$dropXOffset = 55;
var _user$project$IV_Apparatus_ViewConstants$hoseXOffset = _user$project$IV_Apparatus_ViewConstants$dropXOffset;
var _user$project$IV_Apparatus_ViewConstants$puddleHeight = 20;
var _user$project$IV_Apparatus_ViewConstants$chamberHeight = 90;
var _user$project$IV_Apparatus_ViewConstants$chamberWidth = 30;
var _user$project$IV_Apparatus_ViewConstants$chamberXOffset = 45;
var _user$project$IV_Apparatus_ViewConstants$bagHeight = 200;
var _user$project$IV_Apparatus_ViewConstants$chamberYOffset = _user$project$IV_Apparatus_ViewConstants$bagHeight;
var _user$project$IV_Apparatus_ViewConstants$chamberOrigin = {ctor: '_Tuple2', _0: _user$project$IV_Apparatus_ViewConstants$chamberXOffset, _1: _user$project$IV_Apparatus_ViewConstants$chamberYOffset};
var _user$project$IV_Apparatus_ViewConstants$puddleYOffset = (_user$project$IV_Apparatus_ViewConstants$chamberYOffset + _user$project$IV_Apparatus_ViewConstants$chamberHeight) - _user$project$IV_Apparatus_ViewConstants$puddleHeight;
var _user$project$IV_Apparatus_ViewConstants$streamHeight = _user$project$IV_Apparatus_ViewConstants$puddleYOffset - _user$project$IV_Apparatus_ViewConstants$chamberYOffset;
var _user$project$IV_Apparatus_ViewConstants$hoseYOffset = _user$project$IV_Apparatus_ViewConstants$chamberYOffset + _user$project$IV_Apparatus_ViewConstants$chamberHeight;
var _user$project$IV_Apparatus_ViewConstants$hoseOrigin = {ctor: '_Tuple2', _0: _user$project$IV_Apparatus_ViewConstants$hoseXOffset, _1: _user$project$IV_Apparatus_ViewConstants$hoseYOffset};
var _user$project$IV_Apparatus_ViewConstants$bagWidth = 120;
var _user$project$IV_Apparatus_ViewConstants$bagOrigin = {ctor: '_Tuple2', _0: 0, _1: 0};

var _user$project$IV_Apparatus_BagView$marking = function (n) {
	var ypos = 20 * n;
	return A2(
		_elm_lang$svg$Svg$line,
		{
			ctor: '::',
			_0: _user$project$IV_Pile_SvgAttributes$x1_(0),
			_1: {
				ctor: '::',
				_0: _user$project$IV_Pile_SvgAttributes$x2_(30),
				_1: {
					ctor: '::',
					_0: _user$project$IV_Pile_SvgAttributes$y1_(ypos),
					_1: {
						ctor: '::',
						_0: _user$project$IV_Pile_SvgAttributes$y2_(ypos),
						_1: {
							ctor: '::',
							_0: _elm_lang$svg$Svg_Attributes$stroke('black'),
							_1: {ctor: '[]'}
						}
					}
				}
			}
		},
		{ctor: '[]'});
};
var _user$project$IV_Apparatus_BagView$markings = A2(
	_elm_lang$svg$Svg$g,
	{ctor: '[]'},
	A2(
		_elm_lang$core$List$map,
		_user$project$IV_Apparatus_BagView$marking,
		A2(_elm_lang$core$List$range, 1, 9)));
var _user$project$IV_Apparatus_BagView$animationClockTick = F2(
	function (tick, animationState) {
		return A2(_user$project$IV_Apparatus_DrainingRectangle$continueDraining, tick, animationState);
	});
var _user$project$IV_Apparatus_BagView$configuration = {
	containerWidth: _user$project$IV_Apparatus_ViewConstants$bagWidth,
	containerHeight: _user$project$IV_Apparatus_ViewConstants$bagHeight,
	fillColor: _user$project$IV_Apparatus_ViewConstants$fluidColorString,
	extraFigures: {
		ctor: '::',
		_0: _user$project$IV_Apparatus_BagView$markings,
		_1: {ctor: '[]'}
	}
};
var _user$project$IV_Apparatus_BagView$view = function (animationState) {
	return A3(_user$project$IV_Apparatus_DrainingRectangle$render, _user$project$IV_Apparatus_BagView$configuration, _user$project$IV_Apparatus_ViewConstants$bagOrigin, animationState);
};
var _user$project$IV_Apparatus_BagView$startingState = function (level) {
	return A2(_user$project$IV_Apparatus_DrainingRectangle$startingState, _user$project$IV_Apparatus_BagView$configuration, level);
};
var _user$project$IV_Apparatus_BagView$startDraining = F2(
	function (drainage, animationState) {
		var _p0 = drainage;
		if (_p0.ctor === 'FullyEmptied') {
			return A4(_user$project$IV_Apparatus_DrainingRectangle$drainThenSend, _user$project$IV_Apparatus_BagView$configuration, _p0._0, animationState, _user$project$IV_Msg$FluidRanOut);
		} else {
			return A4(_user$project$IV_Apparatus_DrainingRectangle$drainPartially, _user$project$IV_Apparatus_BagView$configuration, _p0._0, _p0._1, animationState);
		}
	});

var _user$project$IV_Apparatus_ChamberView$animationClockTick = F2(
	function (tick, animationState) {
		return A2(_user$project$IV_Apparatus_DrainingRectangle$continueDraining, tick, animationState);
	});
var _user$project$IV_Apparatus_ChamberView$configuration = {
	containerWidth: _user$project$IV_Apparatus_ViewConstants$chamberWidth,
	containerHeight: _user$project$IV_Apparatus_ViewConstants$chamberHeight,
	fillColor: _user$project$IV_Apparatus_ViewConstants$fluidColorString,
	extraFigures: {ctor: '[]'}
};
var _user$project$IV_Apparatus_ChamberView$view = function (animationState) {
	return A3(_user$project$IV_Apparatus_DrainingRectangle$render, _user$project$IV_Apparatus_ChamberView$configuration, _user$project$IV_Apparatus_ViewConstants$chamberOrigin, animationState);
};
var _user$project$IV_Apparatus_ChamberView$startDraining = function (animationState) {
	return A4(
		_user$project$IV_Apparatus_DrainingRectangle$drainThenSend,
		_user$project$IV_Apparatus_ChamberView$configuration,
		_user$project$IV_Types$Hours(0.4),
		animationState,
		_user$project$IV_Msg$ChamberEmptied);
};
var _user$project$IV_Apparatus_ChamberView$startingLevel = _user$project$IV_Types$Level(
	_elm_lang$core$Basics$toFloat(_user$project$IV_Apparatus_ViewConstants$puddleHeight) / _elm_lang$core$Basics$toFloat(_user$project$IV_Apparatus_ViewConstants$chamberHeight));
var _user$project$IV_Apparatus_ChamberView$startingState = A2(_user$project$IV_Apparatus_DrainingRectangle$startingState, _user$project$IV_Apparatus_ChamberView$configuration, _user$project$IV_Apparatus_ChamberView$startingLevel);

var _user$project$IV_Apparatus_DropletView$finalSliverOfFlowShape = {
	ctor: '::',
	_0: {ctor: '_Tuple2', _0: 0, _1: 0},
	_1: {
		ctor: '::',
		_0: {ctor: '_Tuple2', _0: _user$project$IV_Apparatus_ViewConstants$dropWidth, _1: 0},
		_1: {
			ctor: '::',
			_0: {ctor: '_Tuple2', _0: _user$project$IV_Apparatus_ViewConstants$dropWidth, _1: 0},
			_1: {
				ctor: '::',
				_0: {ctor: '_Tuple2', _0: 0, _1: 0},
				_1: {ctor: '[]'}
			}
		}
	}
};
var _user$project$IV_Apparatus_DropletView$flowShape = {
	ctor: '::',
	_0: {ctor: '_Tuple2', _0: 0, _1: 0},
	_1: {
		ctor: '::',
		_0: {ctor: '_Tuple2', _0: _user$project$IV_Apparatus_ViewConstants$dropWidth, _1: 0},
		_1: {
			ctor: '::',
			_0: {ctor: '_Tuple2', _0: _user$project$IV_Apparatus_ViewConstants$dropWidth, _1: _user$project$IV_Apparatus_ViewConstants$streamHeight},
			_1: {
				ctor: '::',
				_0: {ctor: '_Tuple2', _0: 0, _1: _user$project$IV_Apparatus_ViewConstants$streamHeight},
				_1: {ctor: '[]'}
			}
		}
	}
};
var _user$project$IV_Apparatus_DropletView$dropShape = {
	ctor: '::',
	_0: {ctor: '_Tuple2', _0: 0, _1: 0},
	_1: {
		ctor: '::',
		_0: {ctor: '_Tuple2', _0: _user$project$IV_Apparatus_ViewConstants$dropWidth, _1: 0},
		_1: {
			ctor: '::',
			_0: {ctor: '_Tuple2', _0: _user$project$IV_Apparatus_ViewConstants$dropWidth, _1: _user$project$IV_Apparatus_ViewConstants$dropHeight},
			_1: {
				ctor: '::',
				_0: {ctor: '_Tuple2', _0: 0, _1: _user$project$IV_Apparatus_ViewConstants$dropHeight},
				_1: {ctor: '[]'}
			}
		}
	}
};
var _user$project$IV_Apparatus_DropletView$translateBy = F2(
	function (_p0, points) {
		var _p1 = _p0;
		return A2(
			_elm_lang$core$List$map,
			function (_p2) {
				var _p3 = _p2;
				return {ctor: '_Tuple2', _0: _p3._0 + _p1._0, _1: _p3._1 + _p1._1};
			},
			points);
	});
var _user$project$IV_Apparatus_DropletView$dropAtTop = A2(
	_user$project$IV_Apparatus_DropletView$translateBy,
	{ctor: '_Tuple2', _0: _user$project$IV_Apparatus_ViewConstants$dropXOffset, _1: _user$project$IV_Apparatus_ViewConstants$chamberYOffset},
	_user$project$IV_Apparatus_DropletView$dropShape);
var _user$project$IV_Apparatus_DropletView$dropInFluidAtBottom = A2(
	_user$project$IV_Apparatus_DropletView$translateBy,
	{ctor: '_Tuple2', _0: _user$project$IV_Apparatus_ViewConstants$dropXOffset, _1: _user$project$IV_Apparatus_ViewConstants$puddleYOffset},
	_user$project$IV_Apparatus_DropletView$dropShape);
var _user$project$IV_Apparatus_DropletView$flowInChamber = A2(
	_user$project$IV_Apparatus_DropletView$translateBy,
	{ctor: '_Tuple2', _0: _user$project$IV_Apparatus_ViewConstants$dropXOffset, _1: _user$project$IV_Apparatus_ViewConstants$chamberYOffset},
	_user$project$IV_Apparatus_DropletView$flowShape);
var _user$project$IV_Apparatus_DropletView$finalSliverInChamber = A2(
	_user$project$IV_Apparatus_DropletView$translateBy,
	{ctor: '_Tuple2', _0: _user$project$IV_Apparatus_ViewConstants$dropXOffset, _1: _user$project$IV_Apparatus_ViewConstants$chamberYOffset},
	_user$project$IV_Apparatus_DropletView$finalSliverOfFlowShape);
var _user$project$IV_Apparatus_DropletView$streamRunsOut = {
	ctor: '::',
	_0: _mdgriffith$elm_style_animation$Animation$points(_user$project$IV_Apparatus_DropletView$finalSliverInChamber),
	_1: {
		ctor: '::',
		_0: _mdgriffith$elm_style_animation$Animation$fill(_user$project$IV_Apparatus_ViewConstants$fluidColor),
		_1: {ctor: '[]'}
	}
};
var _user$project$IV_Apparatus_DropletView$streamState2 = {
	ctor: '::',
	_0: _mdgriffith$elm_style_animation$Animation$points(_user$project$IV_Apparatus_DropletView$flowInChamber),
	_1: {
		ctor: '::',
		_0: _mdgriffith$elm_style_animation$Animation$fill(_user$project$IV_Apparatus_ViewConstants$variantFluidColor),
		_1: {ctor: '[]'}
	}
};
var _user$project$IV_Apparatus_DropletView$streamState1 = {
	ctor: '::',
	_0: _mdgriffith$elm_style_animation$Animation$points(_user$project$IV_Apparatus_DropletView$flowInChamber),
	_1: {
		ctor: '::',
		_0: _mdgriffith$elm_style_animation$Animation$fill(_user$project$IV_Apparatus_ViewConstants$fluidColor),
		_1: {ctor: '[]'}
	}
};
var _user$project$IV_Apparatus_DropletView$fallenDrop = {
	ctor: '::',
	_0: _mdgriffith$elm_style_animation$Animation$points(_user$project$IV_Apparatus_DropletView$dropInFluidAtBottom),
	_1: {ctor: '[]'}
};
var _user$project$IV_Apparatus_DropletView$hangingDrop = {
	ctor: '::',
	_0: _mdgriffith$elm_style_animation$Animation$points(_user$project$IV_Apparatus_DropletView$dropAtTop),
	_1: {
		ctor: '::',
		_0: _mdgriffith$elm_style_animation$Animation$fill(_user$project$IV_Apparatus_ViewConstants$fluidColor),
		_1: {ctor: '[]'}
	}
};
var _user$project$IV_Apparatus_DropletView$missingDrop = {
	ctor: '::',
	_0: _mdgriffith$elm_style_animation$Animation$points(_user$project$IV_Apparatus_DropletView$dropAtTop),
	_1: {
		ctor: '::',
		_0: _mdgriffith$elm_style_animation$Animation$fill(_user$project$IV_Apparatus_ViewConstants$whiteColor),
		_1: {ctor: '[]'}
	}
};
var _user$project$IV_Apparatus_DropletView$view = function (model) {
	return A2(
		_elm_lang$svg$Svg$polygon,
		_mdgriffith$elm_style_animation$Animation$render(model),
		{ctor: '[]'});
};

var _user$project$IV_Apparatus_Droplet$animationClockTick = F2(
	function (tick, model) {
		return A2(_mdgriffith$elm_style_animation$Animation_Messenger$update, tick, model);
	});
var _user$project$IV_Apparatus_Droplet$guaranteedFlow = _user$project$IV_Types$DropsPerSecond(10.0);
var _user$project$IV_Apparatus_Droplet$dropStreamCutoff = _user$project$IV_Types$DropsPerSecond(8.0);
var _user$project$IV_Apparatus_Droplet$fallingTime = _user$project$IV_Types$asDuration(_user$project$IV_Apparatus_Droplet$dropStreamCutoff);
var _user$project$IV_Apparatus_Droplet$fallingDrop = function (dropsPerSecond) {
	var totalTime = _user$project$IV_Types$asDuration(dropsPerSecond);
	var hangingTime = totalTime - _user$project$IV_Apparatus_Droplet$fallingTime;
	return {
		ctor: '::',
		_0: _mdgriffith$elm_style_animation$Animation$set(_user$project$IV_Apparatus_DropletView$missingDrop),
		_1: {
			ctor: '::',
			_0: A2(
				_mdgriffith$elm_style_animation$Animation$toWith,
				_user$project$IV_Pile_Animation$linearEasing(hangingTime),
				_user$project$IV_Apparatus_DropletView$hangingDrop),
			_1: {
				ctor: '::',
				_0: A2(
					_mdgriffith$elm_style_animation$Animation$toWith,
					_user$project$IV_Pile_Animation$linearEasing(_user$project$IV_Apparatus_Droplet$fallingTime),
					_user$project$IV_Apparatus_DropletView$fallenDrop),
				_1: {ctor: '[]'}
			}
		}
	};
};
var _user$project$IV_Apparatus_Droplet$steadyStream = {
	ctor: '::',
	_0: A2(
		_mdgriffith$elm_style_animation$Animation$toWith,
		_user$project$IV_Pile_Animation$linearEasing(_user$project$IV_Apparatus_Droplet$fallingTime),
		_user$project$IV_Apparatus_DropletView$streamState1),
	_1: {
		ctor: '::',
		_0: A2(
			_mdgriffith$elm_style_animation$Animation$toWith,
			_user$project$IV_Pile_Animation$linearEasing(_user$project$IV_Apparatus_Droplet$fallingTime),
			_user$project$IV_Apparatus_DropletView$streamState2),
		_1: {ctor: '[]'}
	}
};
var _user$project$IV_Apparatus_Droplet$animationSteps = function (dropsPerSecond) {
	var _p0 = dropsPerSecond;
	var raw = _p0._0;
	return (_elm_lang$core$Native_Utils.cmp(raw, 8.0) > 0) ? _user$project$IV_Apparatus_Droplet$steadyStream : _user$project$IV_Apparatus_Droplet$fallingDrop(dropsPerSecond);
};
var _user$project$IV_Apparatus_Droplet$changeDropRate = F2(
	function (dropsPerSecond, animation) {
		var loop = _mdgriffith$elm_style_animation$Animation$loop(
			_user$project$IV_Apparatus_Droplet$animationSteps(dropsPerSecond));
		return A2(
			_mdgriffith$elm_style_animation$Animation$interrupt,
			{
				ctor: '::',
				_0: loop,
				_1: {ctor: '[]'}
			},
			animation);
	});
var _user$project$IV_Apparatus_Droplet$showTrueFlow = F2(
	function (perSecond, model) {
		return A2(
			_elm_lang$core$Platform_Cmd_ops['!'],
			A2(_user$project$IV_Apparatus_Droplet$changeDropRate, perSecond, model),
			{ctor: '[]'});
	});
var _user$project$IV_Apparatus_Droplet$showTimeLapseFlow = function (model) {
	return A2(
		_elm_lang$core$Platform_Cmd_ops['!'],
		A2(_user$project$IV_Apparatus_Droplet$changeDropRate, _user$project$IV_Apparatus_Droplet$guaranteedFlow, model),
		{ctor: '[]'});
};
var _user$project$IV_Apparatus_Droplet$noDrips = _mdgriffith$elm_style_animation$Animation$style(_user$project$IV_Apparatus_DropletView$missingDrop);

var _user$project$IV_Apparatus_HoseView$animationClockTick = F2(
	function (tick, animationState) {
		return A2(_user$project$IV_Apparatus_DrainingRectangle$continueDraining, tick, animationState);
	});
var _user$project$IV_Apparatus_HoseView$configuration = {
	containerWidth: _user$project$IV_Apparatus_ViewConstants$hoseWidth,
	containerHeight: _user$project$IV_Apparatus_ViewConstants$hoseHeight,
	fillColor: _user$project$IV_Apparatus_ViewConstants$fluidColorString,
	extraFigures: {ctor: '[]'}
};
var _user$project$IV_Apparatus_HoseView$view = function (animationState) {
	return A3(_user$project$IV_Apparatus_DrainingRectangle$render, _user$project$IV_Apparatus_HoseView$configuration, _user$project$IV_Apparatus_ViewConstants$hoseOrigin, animationState);
};
var _user$project$IV_Apparatus_HoseView$startingState = A2(
	_user$project$IV_Apparatus_DrainingRectangle$startingState,
	_user$project$IV_Apparatus_HoseView$configuration,
	_user$project$IV_Types$Level(1.0));
var _user$project$IV_Apparatus_HoseView$startDraining = function (animationState) {
	return A3(
		_user$project$IV_Apparatus_DrainingRectangle$drain,
		_user$project$IV_Apparatus_HoseView$configuration,
		_user$project$IV_Types$Hours(0.2),
		animationState);
};

var _user$project$IV_Apparatus_Lenses$apparatus_rate = function () {
	var set = F2(
		function (new2, arg1) {
			return _elm_lang$core$Native_Utils.update(
				arg1,
				{rate: new2});
		});
	var get = function (arg1) {
		return arg1.rate;
	};
	return A2(_arturopala$elm_monocle$Monocle_Lens$Lens, get, set);
}();
var _user$project$IV_Apparatus_Lenses$apparatus_hoseFluid = function () {
	var set = F2(
		function (new2, arg1) {
			return _elm_lang$core$Native_Utils.update(
				arg1,
				{hoseFluid: new2});
		});
	var get = function (arg1) {
		return arg1.hoseFluid;
	};
	return A2(_arturopala$elm_monocle$Monocle_Lens$Lens, get, set);
}();
var _user$project$IV_Apparatus_Lenses$apparatus_chamberFluid = function () {
	var set = F2(
		function (new2, arg1) {
			return _elm_lang$core$Native_Utils.update(
				arg1,
				{chamberFluid: new2});
		});
	var get = function (arg1) {
		return arg1.chamberFluid;
	};
	return A2(_arturopala$elm_monocle$Monocle_Lens$Lens, get, set);
}();
var _user$project$IV_Apparatus_Lenses$apparatus_bagLevel = function () {
	var set = F2(
		function (new2, arg1) {
			return _elm_lang$core$Native_Utils.update(
				arg1,
				{bagLevel: new2});
		});
	var get = function (arg1) {
		return arg1.bagLevel;
	};
	return A2(_arturopala$elm_monocle$Monocle_Lens$Lens, get, set);
}();
var _user$project$IV_Apparatus_Lenses$apparatus_droplet = function () {
	var set = F2(
		function (new2, arg1) {
			return _elm_lang$core$Native_Utils.update(
				arg1,
				{droplet: new2});
		});
	var get = function (arg1) {
		return arg1.droplet;
	};
	return A2(_arturopala$elm_monocle$Monocle_Lens$Lens, get, set);
}();
var _user$project$IV_Apparatus_Lenses$updateRate = function (f) {
	return A2(_user$project$IV_Pile_CmdFlow$update, _user$project$IV_Apparatus_Lenses$apparatus_rate, f);
};
var _user$project$IV_Apparatus_Lenses$updateHoseFluid = function (f) {
	return A2(_user$project$IV_Pile_CmdFlow$update, _user$project$IV_Apparatus_Lenses$apparatus_hoseFluid, f);
};
var _user$project$IV_Apparatus_Lenses$updateChamberFluid = function (f) {
	return A2(_user$project$IV_Pile_CmdFlow$update, _user$project$IV_Apparatus_Lenses$apparatus_chamberFluid, f);
};
var _user$project$IV_Apparatus_Lenses$updateBagLevel = function (f) {
	return A2(_user$project$IV_Pile_CmdFlow$update, _user$project$IV_Apparatus_Lenses$apparatus_bagLevel, f);
};
var _user$project$IV_Apparatus_Lenses$updateDroplet = function (f) {
	return A2(_user$project$IV_Pile_CmdFlow$update, _user$project$IV_Apparatus_Lenses$apparatus_droplet, f);
};
var _user$project$IV_Apparatus_Lenses$flow = _user$project$IV_Pile_CmdFlow$flow;

var _user$project$IV_Apparatus_Main$animationClockTick = F2(
	function (tick, model) {
		return A2(
			_user$project$IV_Apparatus_Lenses$updateHoseFluid,
			_user$project$IV_Apparatus_HoseView$animationClockTick(tick),
			A2(
				_user$project$IV_Apparatus_Lenses$updateChamberFluid,
				_user$project$IV_Apparatus_ChamberView$animationClockTick(tick),
				A2(
					_user$project$IV_Apparatus_Lenses$updateBagLevel,
					_user$project$IV_Apparatus_BagView$animationClockTick(tick),
					A2(
						_user$project$IV_Apparatus_Lenses$updateDroplet,
						_user$project$IV_Apparatus_Droplet$animationClockTick(tick),
						_user$project$IV_Apparatus_Lenses$flow(model)))));
	});
var _user$project$IV_Apparatus_Main$startSimulation = F2(
	function (drainage, model) {
		return A2(
			_user$project$IV_Apparatus_Lenses$updateBagLevel,
			_user$project$IV_Apparatus_BagView$startDraining(drainage),
			A2(
				_user$project$IV_Apparatus_Lenses$updateDroplet,
				_user$project$IV_Apparatus_Droplet$showTimeLapseFlow,
				_user$project$IV_Apparatus_Lenses$flow(model)));
	});
var _user$project$IV_Apparatus_Main$drainHose = function (model) {
	return A2(
		_user$project$IV_Apparatus_Lenses$updateHoseFluid,
		_user$project$IV_Apparatus_HoseView$startDraining,
		_user$project$IV_Apparatus_Lenses$flow(model));
};
var _user$project$IV_Apparatus_Main$drainChamber = function (model) {
	return A2(
		_user$project$IV_Apparatus_Lenses$updateChamberFluid,
		_user$project$IV_Apparatus_ChamberView$startDraining,
		_user$project$IV_Apparatus_Lenses$flow(model));
};
var _user$project$IV_Apparatus_Main$changeDripRate = F2(
	function (dropsPerSecond, model) {
		return {
			ctor: '_Tuple2',
			_0: A2(_user$project$IV_Apparatus_Lenses$apparatus_rate.set, dropsPerSecond, model),
			_1: _elm_lang$core$Platform_Cmd$none
		};
	});
var _user$project$IV_Apparatus_Main$showTrueFlow = function (model) {
	return A2(
		_user$project$IV_Apparatus_Lenses$updateDroplet,
		_user$project$IV_Apparatus_Droplet$showTrueFlow(model.rate),
		_user$project$IV_Apparatus_Lenses$flow(model));
};
var _user$project$IV_Apparatus_Main$unstarted = function (startingLevel) {
	return {
		droplet: _user$project$IV_Apparatus_Droplet$noDrips,
		bagLevel: _user$project$IV_Apparatus_BagView$startingState(startingLevel),
		chamberFluid: _user$project$IV_Apparatus_ChamberView$startingState,
		hoseFluid: _user$project$IV_Apparatus_HoseView$startingState,
		rate: _user$project$IV_Types$DropsPerSecond(0)
	};
};
var _user$project$IV_Apparatus_Main$animations = function (model) {
	return {
		ctor: '::',
		_0: model.droplet,
		_1: {
			ctor: '::',
			_0: model.bagLevel,
			_1: {
				ctor: '::',
				_0: model.chamberFluid,
				_1: {
					ctor: '::',
					_0: model.hoseFluid,
					_1: {ctor: '[]'}
				}
			}
		}
	};
};
var _user$project$IV_Apparatus_Main$Model = F5(
	function (a, b, c, d, e) {
		return {droplet: a, bagLevel: b, chamberFluid: c, hoseFluid: d, rate: e};
	});

var _user$project$IV_Clock_ViewConstants$hourMarkersLineLength = 80;
var _user$project$IV_Clock_ViewConstants$numeralFontSize = '20px';
var _user$project$IV_Clock_ViewConstants$numeralOffset = 10;
var _user$project$IV_Clock_ViewConstants$radius = 100;
var _user$project$IV_Clock_ViewConstants$hourHandLength = (_user$project$IV_Clock_ViewConstants$radius / 3) | 0;
var _user$project$IV_Clock_ViewConstants$minuteHandLength = 2 * _user$project$IV_Clock_ViewConstants$hourHandLength;
var _user$project$IV_Clock_ViewConstants$centerY = 200;
var _user$project$IV_Clock_ViewConstants$centerX = 260;

var _user$project$IV_Clock_Face$clockNumeral = function (value) {
	var xy = function () {
		var _p0 = value;
		switch (_p0) {
			case 12:
				return {
					ctor: '::',
					_0: _user$project$IV_Pile_SvgAttributes$x_(_user$project$IV_Clock_ViewConstants$centerX),
					_1: {
						ctor: '::',
						_0: _user$project$IV_Pile_SvgAttributes$y_((_user$project$IV_Clock_ViewConstants$centerY - _user$project$IV_Clock_ViewConstants$radius) + _user$project$IV_Clock_ViewConstants$numeralOffset),
						_1: {ctor: '[]'}
					}
				};
			case 3:
				return {
					ctor: '::',
					_0: _user$project$IV_Pile_SvgAttributes$x_((_user$project$IV_Clock_ViewConstants$centerX + _user$project$IV_Clock_ViewConstants$radius) - _user$project$IV_Clock_ViewConstants$numeralOffset),
					_1: {
						ctor: '::',
						_0: _user$project$IV_Pile_SvgAttributes$y_(_user$project$IV_Clock_ViewConstants$centerY),
						_1: {ctor: '[]'}
					}
				};
			case 6:
				return {
					ctor: '::',
					_0: _user$project$IV_Pile_SvgAttributes$x_(_user$project$IV_Clock_ViewConstants$centerX),
					_1: {
						ctor: '::',
						_0: _user$project$IV_Pile_SvgAttributes$y_((_user$project$IV_Clock_ViewConstants$centerY + _user$project$IV_Clock_ViewConstants$radius) - _user$project$IV_Clock_ViewConstants$numeralOffset),
						_1: {ctor: '[]'}
					}
				};
			case 9:
				return {
					ctor: '::',
					_0: _user$project$IV_Pile_SvgAttributes$x_((_user$project$IV_Clock_ViewConstants$centerX - _user$project$IV_Clock_ViewConstants$radius) + _user$project$IV_Clock_ViewConstants$numeralOffset),
					_1: {
						ctor: '::',
						_0: _user$project$IV_Pile_SvgAttributes$y_(_user$project$IV_Clock_ViewConstants$centerY),
						_1: {ctor: '[]'}
					}
				};
			default:
				return {ctor: '[]'};
		}
	}();
	var common = {
		ctor: '::',
		_0: _elm_lang$svg$Svg_Attributes$fontSize(_user$project$IV_Clock_ViewConstants$numeralFontSize),
		_1: {
			ctor: '::',
			_0: _elm_lang$svg$Svg_Attributes$dy('.3em'),
			_1: {
				ctor: '::',
				_0: _elm_lang$svg$Svg_Attributes$textAnchor('middle'),
				_1: {ctor: '[]'}
			}
		}
	};
	return A2(
		_elm_lang$svg$Svg$text_,
		A2(_elm_lang$core$Basics_ops['++'], common, xy),
		{
			ctor: '::',
			_0: _elm_lang$svg$Svg$text(
				_elm_lang$core$Basics$toString(value)),
			_1: {ctor: '[]'}
		});
};
var _user$project$IV_Clock_Face$spacedInt = A2(
	_krisajenkins$formatting$Formatting_ops['<>'],
	_krisajenkins$formatting$Formatting$s(' '),
	A2(
		_krisajenkins$formatting$Formatting_ops['<>'],
		_krisajenkins$formatting$Formatting$int,
		_krisajenkins$formatting$Formatting$s(' ')));
var _user$project$IV_Clock_Face$rotate_ = F3(
	function (degrees, xCenter, yCenter) {
		var fmt = A2(
			_krisajenkins$formatting$Formatting_ops['<>'],
			_krisajenkins$formatting$Formatting$s('rotate('),
			A2(
				_krisajenkins$formatting$Formatting_ops['<>'],
				_user$project$IV_Clock_Face$spacedInt,
				A2(
					_krisajenkins$formatting$Formatting_ops['<>'],
					_user$project$IV_Clock_Face$spacedInt,
					A2(
						_krisajenkins$formatting$Formatting_ops['<>'],
						_user$project$IV_Clock_Face$spacedInt,
						_krisajenkins$formatting$Formatting$s(')')))));
		return A4(_krisajenkins$formatting$Formatting$print, fmt, degrees, xCenter, yCenter);
	});
var _user$project$IV_Clock_Face$transformForHour = function (hour) {
	return _elm_lang$svg$Svg_Attributes$transform(
		A3(_user$project$IV_Clock_Face$rotate_, hour * 30, _user$project$IV_Clock_ViewConstants$centerX, _user$project$IV_Clock_ViewConstants$centerY));
};
var _user$project$IV_Clock_Face$hourMarkers = function (hour) {
	return A2(
		_elm_lang$svg$Svg$line,
		{
			ctor: '::',
			_0: _user$project$IV_Pile_SvgAttributes$x1_(_user$project$IV_Clock_ViewConstants$centerX),
			_1: {
				ctor: '::',
				_0: _user$project$IV_Pile_SvgAttributes$y1_(_user$project$IV_Clock_ViewConstants$centerY),
				_1: {
					ctor: '::',
					_0: _user$project$IV_Pile_SvgAttributes$x2_(_user$project$IV_Clock_ViewConstants$centerX),
					_1: {
						ctor: '::',
						_0: _user$project$IV_Pile_SvgAttributes$y2_(_user$project$IV_Clock_ViewConstants$centerY - _user$project$IV_Clock_ViewConstants$hourMarkersLineLength),
						_1: {
							ctor: '::',
							_0: _elm_lang$svg$Svg_Attributes$stroke('#000'),
							_1: {
								ctor: '::',
								_0: _elm_lang$svg$Svg_Attributes$strokeWidth('1'),
								_1: {
									ctor: '::',
									_0: _user$project$IV_Clock_Face$transformForHour(hour),
									_1: {ctor: '[]'}
								}
							}
						}
					}
				}
			}
		},
		{ctor: '[]'});
};
var _user$project$IV_Clock_Face$view = A2(
	_elm_lang$svg$Svg$g,
	{ctor: '[]'},
	A2(
		_elm_lang$core$Basics_ops['++'],
		{
			ctor: '::',
			_0: A2(
				_elm_lang$svg$Svg$circle,
				{
					ctor: '::',
					_0: _user$project$IV_Pile_SvgAttributes$cx_(_user$project$IV_Clock_ViewConstants$centerX),
					_1: {
						ctor: '::',
						_0: _user$project$IV_Pile_SvgAttributes$cy_(_user$project$IV_Clock_ViewConstants$centerY),
						_1: {
							ctor: '::',
							_0: _user$project$IV_Pile_SvgAttributes$r_(_user$project$IV_Clock_ViewConstants$radius),
							_1: {
								ctor: '::',
								_0: _elm_lang$svg$Svg_Attributes$fill('#0B79CE'),
								_1: {ctor: '[]'}
							}
						}
					}
				},
				{ctor: '[]'}),
			_1: {
				ctor: '::',
				_0: _user$project$IV_Clock_Face$clockNumeral(12),
				_1: {
					ctor: '::',
					_0: _user$project$IV_Clock_Face$clockNumeral(3),
					_1: {
						ctor: '::',
						_0: _user$project$IV_Clock_Face$clockNumeral(6),
						_1: {
							ctor: '::',
							_0: _user$project$IV_Clock_Face$clockNumeral(9),
							_1: {ctor: '[]'}
						}
					}
				}
			}
		},
		A2(
			_elm_lang$core$List$map,
			_user$project$IV_Clock_Face$hourMarkers,
			{
				ctor: '::',
				_0: 12,
				_1: {
					ctor: '::',
					_0: 1,
					_1: {
						ctor: '::',
						_0: 2,
						_1: {
							ctor: '::',
							_0: 3,
							_1: {
								ctor: '::',
								_0: 4,
								_1: {
									ctor: '::',
									_0: 5,
									_1: {
										ctor: '::',
										_0: 6,
										_1: {
											ctor: '::',
											_0: 7,
											_1: {
												ctor: '::',
												_0: 8,
												_1: {
													ctor: '::',
													_0: 9,
													_1: {
														ctor: '::',
														_0: 10,
														_1: {
															ctor: '::',
															_0: 11,
															_1: {ctor: '[]'}
														}
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			})));

var _user$project$IV_Clock_View$handProperties = {
	ctor: '::',
	_0: _user$project$IV_Pile_SvgAttributes$x1_(_user$project$IV_Clock_ViewConstants$centerX),
	_1: {
		ctor: '::',
		_0: _user$project$IV_Pile_SvgAttributes$y1_(_user$project$IV_Clock_ViewConstants$centerY),
		_1: {
			ctor: '::',
			_0: _user$project$IV_Pile_SvgAttributes$x2_(_user$project$IV_Clock_ViewConstants$centerX),
			_1: {
				ctor: '::',
				_0: _elm_lang$svg$Svg_Attributes$stroke('black'),
				_1: {
					ctor: '::',
					_0: _elm_lang$svg$Svg_Attributes$markerEnd('url(#arrow)'),
					_1: {ctor: '[]'}
				}
			}
		}
	}
};
var _user$project$IV_Clock_View$hourHandBaseProperties = A2(
	_elm_lang$core$Basics_ops['++'],
	{
		ctor: '::',
		_0: _user$project$IV_Pile_SvgAttributes$y2_(_user$project$IV_Clock_ViewConstants$centerY - _user$project$IV_Clock_ViewConstants$hourHandLength),
		_1: {
			ctor: '::',
			_0: _elm_lang$svg$Svg_Attributes$strokeWidth('5'),
			_1: {ctor: '[]'}
		}
	},
	_user$project$IV_Clock_View$handProperties);
var _user$project$IV_Clock_View$minuteHandBaseProperties = A2(
	_elm_lang$core$Basics_ops['++'],
	{
		ctor: '::',
		_0: _user$project$IV_Pile_SvgAttributes$y2_(_user$project$IV_Clock_ViewConstants$centerY - _user$project$IV_Clock_ViewConstants$minuteHandLength),
		_1: {
			ctor: '::',
			_0: _elm_lang$svg$Svg_Attributes$strokeWidth('3'),
			_1: {ctor: '[]'}
		}
	},
	_user$project$IV_Clock_View$handProperties);
var _user$project$IV_Clock_View$originAtClockCenter = function () {
	var argFormatter = _krisajenkins$formatting$Formatting$print(
		A2(
			_krisajenkins$formatting$Formatting_ops['<>'],
			_krisajenkins$formatting$Formatting$int,
			A2(
				_krisajenkins$formatting$Formatting_ops['<>'],
				_krisajenkins$formatting$Formatting$s('px '),
				A2(
					_krisajenkins$formatting$Formatting_ops['<>'],
					_krisajenkins$formatting$Formatting$int,
					_krisajenkins$formatting$Formatting$s('px')))));
	return A2(
		_mdgriffith$elm_style_animation$Animation$exactly,
		'transform-origin',
		A2(argFormatter, _user$project$IV_Clock_ViewConstants$centerX, _user$project$IV_Clock_ViewConstants$centerY));
}();
var _user$project$IV_Clock_View$defineArrowhead = A2(
	_elm_lang$svg$Svg$defs,
	{ctor: '[]'},
	{
		ctor: '::',
		_0: A2(
			_elm_lang$svg$Svg$marker,
			{
				ctor: '::',
				_0: _elm_lang$svg$Svg_Attributes$id('arrow'),
				_1: {
					ctor: '::',
					_0: _user$project$IV_Pile_SvgAttributes$markerWidth_(10),
					_1: {
						ctor: '::',
						_0: _user$project$IV_Pile_SvgAttributes$markerHeight_(10),
						_1: {
							ctor: '::',
							_0: _elm_lang$svg$Svg_Attributes$refX('0'),
							_1: {
								ctor: '::',
								_0: _elm_lang$svg$Svg_Attributes$refY('3'),
								_1: {
									ctor: '::',
									_0: _elm_lang$svg$Svg_Attributes$orient('auto'),
									_1: {
										ctor: '::',
										_0: _elm_lang$svg$Svg_Attributes$markerUnits('strokeWidth'),
										_1: {ctor: '[]'}
									}
								}
							}
						}
					}
				}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$svg$Svg$path,
					{
						ctor: '::',
						_0: _elm_lang$svg$Svg_Attributes$d('M0,0 L0,6 L9,3 z'),
						_1: {
							ctor: '::',
							_0: _elm_lang$svg$Svg_Attributes$fill('#f00'),
							_1: {ctor: '[]'}
						}
					},
					{ctor: '[]'}),
				_1: {ctor: '[]'}
			}),
		_1: {ctor: '[]'}
	});
var _user$project$IV_Clock_View$minuteHandStartsAt = function (minute) {
	return {
		ctor: '::',
		_0: _user$project$IV_Clock_View$originAtClockCenter,
		_1: {
			ctor: '::',
			_0: _mdgriffith$elm_style_animation$Animation$rotate(
				_mdgriffith$elm_style_animation$Animation$deg(minute)),
			_1: {ctor: '[]'}
		}
	};
};
var _user$project$IV_Clock_View$hourHandStartsAt = function (hour) {
	return {
		ctor: '::',
		_0: _user$project$IV_Clock_View$originAtClockCenter,
		_1: {
			ctor: '::',
			_0: _mdgriffith$elm_style_animation$Animation$rotate(
				_mdgriffith$elm_style_animation$Animation$deg(30 * hour)),
			_1: {ctor: '[]'}
		}
	};
};
var _user$project$IV_Clock_View$viewHands = function (model) {
	return A2(
		_elm_lang$svg$Svg$g,
		{ctor: '[]'},
		{
			ctor: '::',
			_0: _user$project$IV_Clock_View$defineArrowhead,
			_1: {
				ctor: '::',
				_0: A2(
					_elm_lang$svg$Svg$line,
					A2(
						_elm_lang$core$Basics_ops['++'],
						_mdgriffith$elm_style_animation$Animation$render(model.hourHand),
						_user$project$IV_Clock_View$hourHandBaseProperties),
					{ctor: '[]'}),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$svg$Svg$line,
						A2(
							_elm_lang$core$Basics_ops['++'],
							_mdgriffith$elm_style_animation$Animation$render(model.minuteHand),
							_user$project$IV_Clock_View$minuteHandBaseProperties),
						{ctor: '[]'}),
					_1: {ctor: '[]'}
				}
			}
		});
};
var _user$project$IV_Clock_View$view = function (model) {
	return {
		ctor: '::',
		_0: _user$project$IV_Clock_Face$view,
		_1: {
			ctor: '::',
			_0: _user$project$IV_Clock_View$viewHands(model),
			_1: {ctor: '[]'}
		}
	};
};

var _user$project$IV_Clock_Lenses$clock_minuteHand = function () {
	var set = F2(
		function (new2, arg1) {
			return _elm_lang$core$Native_Utils.update(
				arg1,
				{minuteHand: new2});
		});
	var get = function (arg1) {
		return arg1.minuteHand;
	};
	return A2(_arturopala$elm_monocle$Monocle_Lens$Lens, get, set);
}();
var _user$project$IV_Clock_Lenses$clock_hourHand = function () {
	var set = F2(
		function (new2, arg1) {
			return _elm_lang$core$Native_Utils.update(
				arg1,
				{hourHand: new2});
		});
	var get = function (arg1) {
		return arg1.hourHand;
	};
	return A2(_arturopala$elm_monocle$Monocle_Lens$Lens, get, set);
}();
var _user$project$IV_Clock_Lenses$updateMinuteHand = function (f) {
	return A2(_user$project$IV_Pile_CmdFlow$update, _user$project$IV_Clock_Lenses$clock_minuteHand, f);
};
var _user$project$IV_Clock_Lenses$updateHourHand = function (f) {
	return A2(_user$project$IV_Pile_CmdFlow$update, _user$project$IV_Clock_Lenses$clock_hourHand, f);
};
var _user$project$IV_Clock_Lenses$flow = _user$project$IV_Pile_CmdFlow$flow;

var _user$project$IV_Clock_Main$advance = F4(
	function (animation, hours, rotationF, endMsg) {
		var after = function () {
			var _p0 = endMsg;
			if (_p0.ctor === 'Nothing') {
				return {ctor: '[]'};
			} else {
				return {
					ctor: '::',
					_0: _mdgriffith$elm_style_animation$Animation_Messenger$send(_p0._0),
					_1: {ctor: '[]'}
				};
			}
		}();
		var rotation = _mdgriffith$elm_style_animation$Animation$deg(
			rotationF(hours));
		var rotationStep = A2(
			_mdgriffith$elm_style_animation$Animation$toWith,
			_user$project$IV_Pile_Animation$easeForHours(hours),
			{
				ctor: '::',
				_0: _mdgriffith$elm_style_animation$Animation$rotate(rotation),
				_1: {ctor: '[]'}
			});
		var steps = {ctor: '::', _0: rotationStep, _1: after};
		return A2(
			_elm_lang$core$Platform_Cmd_ops['!'],
			A2(_mdgriffith$elm_style_animation$Animation$interrupt, steps, animation),
			{ctor: '[]'});
	});
var _user$project$IV_Clock_Main$minuteHandRotations = function (_p1) {
	var _p2 = _p1;
	return _p2._0 * 360;
};
var _user$project$IV_Clock_Main$spinMinuteHand = F2(
	function (hours, animation) {
		return A4(_user$project$IV_Clock_Main$advance, animation, hours, _user$project$IV_Clock_Main$minuteHandRotations, _elm_lang$core$Maybe$Nothing);
	});
var _user$project$IV_Clock_Main$animationClockTick = F2(
	function (tick, model) {
		return A2(
			_user$project$IV_Clock_Lenses$updateMinuteHand,
			_mdgriffith$elm_style_animation$Animation_Messenger$update(tick),
			A2(
				_user$project$IV_Clock_Lenses$updateHourHand,
				_mdgriffith$elm_style_animation$Animation_Messenger$update(tick),
				_user$project$IV_Clock_Lenses$flow(model)));
	});
var _user$project$IV_Clock_Main$startingHourRaw = 2;
var _user$project$IV_Clock_Main$startingHour = _user$project$IV_Types$Hours(_user$project$IV_Clock_Main$startingHourRaw);
var _user$project$IV_Clock_Main$startingState = {
	hourHand: _mdgriffith$elm_style_animation$Animation$style(
		_user$project$IV_Clock_View$hourHandStartsAt(_user$project$IV_Clock_Main$startingHourRaw)),
	minuteHand: _mdgriffith$elm_style_animation$Animation$style(
		_user$project$IV_Clock_View$minuteHandStartsAt(0))
};
var _user$project$IV_Clock_Main$hourHandRotations = function (_p3) {
	var _p4 = _p3;
	return (_user$project$IV_Clock_Main$startingHourRaw + _p4._0) * 30;
};
var _user$project$IV_Clock_Main$advanceHourHand = F2(
	function (hours, animation) {
		return A4(
			_user$project$IV_Clock_Main$advance,
			animation,
			hours,
			_user$project$IV_Clock_Main$hourHandRotations,
			_elm_lang$core$Maybe$Just(_user$project$IV_Msg$StopSimulation));
	});
var _user$project$IV_Clock_Main$startSimulation = F2(
	function (hours, model) {
		return A2(
			_user$project$IV_Clock_Lenses$updateMinuteHand,
			_user$project$IV_Clock_Main$spinMinuteHand(hours),
			A2(
				_user$project$IV_Clock_Lenses$updateHourHand,
				_user$project$IV_Clock_Main$advanceHourHand(hours),
				_user$project$IV_Clock_Lenses$flow(model)));
	});
var _user$project$IV_Clock_Main$animations = function (model) {
	return {
		ctor: '::',
		_0: model.hourHand,
		_1: {
			ctor: '::',
			_0: model.minuteHand,
			_1: {ctor: '[]'}
		}
	};
};
var _user$project$IV_Clock_Main$Model = F2(
	function (a, b) {
		return {hourHand: a, minuteHand: b};
	});

var _user$project$IV_Scenario_Lenses$decisions_simulationMinutes = function () {
	var set = F2(
		function (new2, arg1) {
			return _elm_lang$core$Native_Utils.update(
				arg1,
				{simulationMinutes: new2});
		});
	var get = function (arg1) {
		return arg1.simulationMinutes;
	};
	return A2(_arturopala$elm_monocle$Monocle_Lens$Lens, get, set);
}();
var _user$project$IV_Scenario_Lenses$decisions_simulationHours = function () {
	var set = F2(
		function (new2, arg1) {
			return _elm_lang$core$Native_Utils.update(
				arg1,
				{simulationHours: new2});
		});
	var get = function (arg1) {
		return arg1.simulationHours;
	};
	return A2(_arturopala$elm_monocle$Monocle_Lens$Lens, get, set);
}();
var _user$project$IV_Scenario_Lenses$decisions_dripRate = function () {
	var set = F2(
		function (new2, arg1) {
			return _elm_lang$core$Native_Utils.update(
				arg1,
				{dripRate: new2});
		});
	var get = function (arg1) {
		return arg1.dripRate;
	};
	return A2(_arturopala$elm_monocle$Monocle_Lens$Lens, get, set);
}();
var _user$project$IV_Scenario_Lenses$background_dropsPerMil = function () {
	var set = F2(
		function (new2, arg1) {
			return _elm_lang$core$Native_Utils.update(
				arg1,
				{dropsPerMil: new2});
		});
	var get = function (arg1) {
		return arg1.dropsPerMil;
	};
	return A2(_arturopala$elm_monocle$Monocle_Lens$Lens, get, set);
}();
var _user$project$IV_Scenario_Lenses$background_bagContents = function () {
	var set = F2(
		function (new2, arg1) {
			return _elm_lang$core$Native_Utils.update(
				arg1,
				{bagContentsInLiters: new2});
		});
	var get = function (arg1) {
		return arg1.bagContentsInLiters;
	};
	return A2(_arturopala$elm_monocle$Monocle_Lens$Lens, get, set);
}();
var _user$project$IV_Scenario_Lenses$background_tag = function () {
	var set = F2(
		function (new2, arg1) {
			return _elm_lang$core$Native_Utils.update(
				arg1,
				{tag: new2});
		});
	var get = function (arg1) {
		return arg1.tag;
	};
	return A2(_arturopala$elm_monocle$Monocle_Lens$Lens, get, set);
}();
var _user$project$IV_Scenario_Lenses$background_bagCapacity = function () {
	var set = F2(
		function (new2, arg1) {
			return _elm_lang$core$Native_Utils.update(
				arg1,
				{bagCapacityInLiters: new2});
		});
	var get = function (arg1) {
		return arg1.bagCapacityInLiters;
	};
	return A2(_arturopala$elm_monocle$Monocle_Lens$Lens, get, set);
}();
var _user$project$IV_Scenario_Lenses$model_caseBackgroundEditorOpen = function () {
	var set = F2(
		function (new2, arg1) {
			return _elm_lang$core$Native_Utils.update(
				arg1,
				{caseBackgroundEditorOpen: new2});
		});
	var get = function (arg1) {
		return arg1.caseBackgroundEditorOpen;
	};
	return A2(_arturopala$elm_monocle$Monocle_Lens$Lens, get, set);
}();
var _user$project$IV_Scenario_Lenses$model_background = function () {
	var set = F2(
		function (new2, arg1) {
			return _elm_lang$core$Native_Utils.update(
				arg1,
				{background: new2});
		});
	var get = function (arg1) {
		return arg1.background;
	};
	return A2(_arturopala$elm_monocle$Monocle_Lens$Lens, get, set);
}();
var _user$project$IV_Scenario_Lenses$model_tag = A2(_arturopala$elm_monocle$Monocle_Lens$compose, _user$project$IV_Scenario_Lenses$model_background, _user$project$IV_Scenario_Lenses$background_tag);
var _user$project$IV_Scenario_Lenses$model_bagCapacity = A2(_arturopala$elm_monocle$Monocle_Lens$compose, _user$project$IV_Scenario_Lenses$model_background, _user$project$IV_Scenario_Lenses$background_bagCapacity);
var _user$project$IV_Scenario_Lenses$model_bagContents = A2(_arturopala$elm_monocle$Monocle_Lens$compose, _user$project$IV_Scenario_Lenses$model_background, _user$project$IV_Scenario_Lenses$background_bagContents);
var _user$project$IV_Scenario_Lenses$model_dropsPerMil = A2(_arturopala$elm_monocle$Monocle_Lens$compose, _user$project$IV_Scenario_Lenses$model_background, _user$project$IV_Scenario_Lenses$background_dropsPerMil);
var _user$project$IV_Scenario_Lenses$model_decisions = function () {
	var set = F2(
		function (new2, arg1) {
			return _elm_lang$core$Native_Utils.update(
				arg1,
				{decisions: new2});
		});
	var get = function (arg1) {
		return arg1.decisions;
	};
	return A2(_arturopala$elm_monocle$Monocle_Lens$Lens, get, set);
}();
var _user$project$IV_Scenario_Lenses$model_dripRate = A2(_arturopala$elm_monocle$Monocle_Lens$compose, _user$project$IV_Scenario_Lenses$model_decisions, _user$project$IV_Scenario_Lenses$decisions_dripRate);
var _user$project$IV_Scenario_Lenses$model_simulationHours = A2(_arturopala$elm_monocle$Monocle_Lens$compose, _user$project$IV_Scenario_Lenses$model_decisions, _user$project$IV_Scenario_Lenses$decisions_simulationHours);
var _user$project$IV_Scenario_Lenses$model_simulationMinutes = A2(_arturopala$elm_monocle$Monocle_Lens$compose, _user$project$IV_Scenario_Lenses$model_decisions, _user$project$IV_Scenario_Lenses$decisions_simulationMinutes);

var _user$project$IV_Scenario_Main$updateWhen = F4(
	function (candidate, pred, model, lens) {
		return pred(candidate) ? A2(lens.set, candidate, model) : model;
	});
var _user$project$IV_Scenario_Main$update = F2(
	function (msg, model) {
		var _p0 = msg;
		switch (_p0.ctor) {
			case 'ChangedDripText':
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					A4(_user$project$IV_Scenario_Main$updateWhen, _p0._0, _user$project$IV_Pile_ManagedStrings$isValidFloatString, model, _user$project$IV_Scenario_Lenses$model_dripRate),
					{ctor: '[]'});
			case 'ChangedHoursText':
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					A4(_user$project$IV_Scenario_Main$updateWhen, _p0._0, _user$project$IV_Pile_ManagedStrings$isValidIntString, model, _user$project$IV_Scenario_Lenses$model_simulationHours),
					{ctor: '[]'});
			case 'ChangedMinutesText':
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					A4(_user$project$IV_Scenario_Main$updateWhen, _p0._0, _user$project$IV_Pile_ManagedStrings$isValidIntString, model, _user$project$IV_Scenario_Lenses$model_simulationMinutes),
					{ctor: '[]'});
			case 'ChangedBagCapacity':
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					A4(_user$project$IV_Scenario_Main$updateWhen, _p0._0, _user$project$IV_Pile_ManagedStrings$isValidFloatString, model, _user$project$IV_Scenario_Lenses$model_bagCapacity),
					{ctor: '[]'});
			case 'ChangedBagContents':
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					A4(_user$project$IV_Scenario_Main$updateWhen, _p0._0, _user$project$IV_Pile_ManagedStrings$isValidFloatString, model, _user$project$IV_Scenario_Lenses$model_bagContents),
					{ctor: '[]'});
			default:
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					A4(_user$project$IV_Scenario_Main$updateWhen, _p0._0, _user$project$IV_Pile_ManagedStrings$isValidFloatString, model, _user$project$IV_Scenario_Lenses$model_dropsPerMil),
					{ctor: '[]'});
		}
	});
var _user$project$IV_Scenario_Main$closeCaseBackgroundEditor = function (model) {
	return {
		ctor: '_Tuple2',
		_0: A2(_user$project$IV_Scenario_Lenses$model_caseBackgroundEditorOpen.set, false, model),
		_1: _elm_lang$core$Platform_Cmd$none
	};
};
var _user$project$IV_Scenario_Main$openCaseBackgroundEditor = function (model) {
	return {
		ctor: '_Tuple2',
		_0: A2(
			_user$project$IV_Scenario_Lenses$model_decisions.set,
			_user$project$IV_Scenario_Model$emptyDecisions,
			A2(
				_user$project$IV_Scenario_Lenses$model_background.set,
				_user$project$IV_Scenario_Model$emptyBackground,
				A2(_user$project$IV_Scenario_Lenses$model_caseBackgroundEditorOpen.set, true, model))),
		_1: _elm_lang$core$Platform_Cmd$none
	};
};

var _user$project$IV_Main$subscriptions = function (model) {
	return A2(
		_mdgriffith$elm_style_animation$Animation$subscription,
		_user$project$IV_Msg$AnimationClockTick,
		A2(
			_elm_lang$core$Basics_ops['++'],
			_user$project$IV_Apparatus_Main$animations(model.apparatus),
			_user$project$IV_Clock_Main$animations(model.clock)));
};
var _user$project$IV_Main$pageFromLocation = function (location) {
	return A2(_elm_lang$core$String$contains, 'about', location.pathname) ? _user$project$IV_Types$AboutPage : _user$project$IV_Types$MainPage;
};
var _user$project$IV_Main$commandFromPage = function (page) {
	var url = function () {
		var _p0 = page;
		if (_p0.ctor === 'MainPage') {
			return '/iv';
		} else {
			return '/iv/about';
		}
	}();
	return _elm_lang$navigation$Navigation$newUrl(url);
};
var _user$project$IV_Main$animateApparatus = function (tick) {
	return _user$project$IV_Lenses$updateApparatus(
		_user$project$IV_Apparatus_Main$animationClockTick(tick));
};
var _user$project$IV_Main$animateClock = function (tick) {
	return _user$project$IV_Lenses$updateClock(
		_user$project$IV_Clock_Main$animationClockTick(tick));
};
var _user$project$IV_Main$closeCaseBackgroundEditor = _user$project$IV_Lenses$updateScenario(_user$project$IV_Scenario_Main$closeCaseBackgroundEditor);
var _user$project$IV_Main$openCaseBackgroundEditor = _user$project$IV_Lenses$updateScenario(_user$project$IV_Scenario_Main$openCaseBackgroundEditor);
var _user$project$IV_Main$startClock = function (hours) {
	return _user$project$IV_Lenses$updateClock(
		_user$project$IV_Clock_Main$startSimulation(hours));
};
var _user$project$IV_Main$startApparatusSimulation = function (drainage) {
	return _user$project$IV_Lenses$updateApparatus(
		_user$project$IV_Apparatus_Main$startSimulation(drainage));
};
var _user$project$IV_Main$drainHose = _user$project$IV_Lenses$updateApparatus(_user$project$IV_Apparatus_Main$drainHose);
var _user$project$IV_Main$drainChamber = _user$project$IV_Lenses$updateApparatus(_user$project$IV_Apparatus_Main$drainChamber);
var _user$project$IV_Main$showTrueFlow = _user$project$IV_Lenses$updateApparatus(_user$project$IV_Apparatus_Main$showTrueFlow);
var _user$project$IV_Main$changeDripRate = function (dripRate) {
	return _user$project$IV_Lenses$updateApparatus(
		_user$project$IV_Apparatus_Main$changeDripRate(dripRate));
};
var _user$project$IV_Main$initWithScenario = function (scenario) {
	return {
		ctor: '_Tuple2',
		_0: {
			page: _user$project$IV_Types$MainPage,
			scenario: scenario,
			apparatus: _user$project$IV_Apparatus_Main$unstarted(
				_user$project$IV_Scenario_DataExport$startingLevel(scenario)),
			clock: _user$project$IV_Clock_Main$startingState
		},
		_1: _elm_lang$core$Platform_Cmd$none
	};
};
var _user$project$IV_Main$init = function (location) {
	return A2(
		_user$project$IV_Lenses$setPage,
		_user$project$IV_Main$pageFromLocation(location),
		_user$project$IV_Main$initWithScenario(
			_user$project$IV_Scenario_Model$preparedScenario(_user$project$IV_Scenario_Model$cowBackground)));
};
var _user$project$IV_Main$update = F2(
	function (msg, model) {
		var _p1 = msg;
		switch (_p1.ctor) {
			case 'NoticePageChange':
				return {
					ctor: '_Tuple2',
					_0: A2(
						_user$project$IV_Lenses$model_page.set,
						_user$project$IV_Main$pageFromLocation(_p1._0),
						model),
					_1: _elm_lang$core$Platform_Cmd$none
				};
			case 'StartPageChange':
				return {
					ctor: '_Tuple2',
					_0: model,
					_1: _user$project$IV_Main$commandFromPage(_p1._0)
				};
			case 'ToScenario':
				return A2(
					_user$project$IV_Lenses$updateScenario,
					_user$project$IV_Scenario_Main$update(_p1._0),
					_user$project$IV_Lenses$flow(model));
			case 'PickedScenario':
				return _user$project$IV_Main$initWithScenario(_p1._0);
			case 'RestartScenario':
				return _user$project$IV_Main$initWithScenario(
					_user$project$IV_Scenario_Model$withEmptiedDecisions(model.scenario));
			case 'ChoseDripRate':
				return _user$project$IV_Main$showTrueFlow(
					A2(
						_user$project$IV_Main$changeDripRate,
						_p1._0,
						_user$project$IV_Lenses$flow(model)));
			case 'FluidRanOut':
				return _user$project$IV_Main$drainChamber(
					_user$project$IV_Main$showTrueFlow(
						A2(
							_user$project$IV_Main$changeDripRate,
							_user$project$IV_Types$DropsPerSecond(0),
							_user$project$IV_Lenses$flow(model))));
			case 'ChamberEmptied':
				return _user$project$IV_Main$drainHose(
					_user$project$IV_Lenses$flow(model));
			case 'StartSimulation':
				var _p2 = _p1._0;
				return A2(
					_user$project$IV_Main$startClock,
					_p2.totalHours,
					A2(
						_user$project$IV_Main$startApparatusSimulation,
						_p2.drainage,
						_user$project$IV_Lenses$flow(model)));
			case 'StopSimulation':
				return _user$project$IV_Main$showTrueFlow(
					_user$project$IV_Lenses$flow(model));
			case 'OpenCaseBackgroundEditor':
				return _user$project$IV_Main$showTrueFlow(
					_user$project$IV_Main$openCaseBackgroundEditor(
						_user$project$IV_Lenses$flow(model)));
			case 'CloseCaseBackgroundEditor':
				return _user$project$IV_Main$closeCaseBackgroundEditor(
					_user$project$IV_Main$initWithScenario(model.scenario));
			default:
				var _p3 = _p1._0;
				return A2(
					_user$project$IV_Main$animateApparatus,
					_p3,
					A2(
						_user$project$IV_Main$animateClock,
						_p3,
						_user$project$IV_Lenses$flow(model)));
		}
	});
var _user$project$IV_Main$Model = F4(
	function (a, b, c, d) {
		return {page: a, scenario: b, clock: c, apparatus: d};
	});

var _user$project$IV_Pile_HtmlShorthand$pSimple = function (string) {
	return A2(
		_elm_lang$html$Html$p,
		{ctor: '[]'},
		{
			ctor: '::',
			_0: _elm_lang$html$Html$text(string),
			_1: {ctor: '[]'}
		});
};
var _user$project$IV_Pile_HtmlShorthand$greyableText = function (beGrey) {
	var color = function () {
		var _p0 = beGrey;
		if (_p0 === true) {
			return 'grey';
		} else {
			return 'black';
		}
	}();
	return _elm_lang$html$Html_Attributes$style(
		{
			ctor: '::',
			_0: {ctor: '_Tuple2', _0: 'color', _1: color},
			_1: {
				ctor: '::',
				_0: {ctor: '_Tuple2', _0: 'background-color', _1: 'white'},
				_1: {ctor: '[]'}
			}
		});
};
var _user$project$IV_Pile_HtmlShorthand$displayStyle = function (toShow) {
	var _p1 = toShow;
	if (_p1 === true) {
		return {ctor: '_Tuple2', _0: 'display', _1: 'block'};
	} else {
		return {ctor: '_Tuple2', _0: 'display', _1: 'none'};
	}
};
var _user$project$IV_Pile_HtmlShorthand$launchWhenDoneButton = F3(
	function (onClick, needsWork, label) {
		return A2(
			_elm_lang$html$Html$button,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Events$onClick(onClick),
				_1: {
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$type_('button'),
					_1: {
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$classList(
							{
								ctor: '::',
								_0: {ctor: '_Tuple2', _0: 'btn', _1: true},
								_1: {
									ctor: '::',
									_0: {ctor: '_Tuple2', _0: 'btn-primary', _1: !needsWork},
									_1: {
										ctor: '::',
										_0: {ctor: '_Tuple2', _0: 'btn-xs', _1: true},
										_1: {ctor: '[]'}
									}
								}
							}),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$disabled(needsWork),
							_1: {ctor: '[]'}
						}
					}
				}
			},
			{
				ctor: '::',
				_0: _elm_lang$html$Html$text(label),
				_1: {ctor: '[]'}
			});
	});
var _user$project$IV_Pile_HtmlShorthand$launchButton = F2(
	function (onClick, label) {
		return A3(_user$project$IV_Pile_HtmlShorthand$launchWhenDoneButton, onClick, false, label);
	});
var _user$project$IV_Pile_HtmlShorthand$textInput = F3(
	function (extraAttributes, value, onInput) {
		return A2(
			_elm_lang$html$Html$input,
			A2(
				_elm_lang$core$Basics_ops['++'],
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$type_('text'),
					_1: {
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$value(value),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$size(6),
							_1: {
								ctor: '::',
								_0: _elm_lang$html$Html_Events$onInput(onInput),
								_1: {ctor: '[]'}
							}
						}
					}
				},
				extraAttributes),
			{ctor: '[]'});
	});
var _user$project$IV_Pile_HtmlShorthand$onClickWithoutPropagation = function (msg) {
	return A3(
		_elm_lang$html$Html_Events$onWithOptions,
		'click',
		{stopPropagation: false, preventDefault: true},
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _user$project$IV_Pile_HtmlShorthand$role = _elm_lang$html$Html_Attributes$attribute('role');
var _user$project$IV_Pile_HtmlShorthand$navElement = function (stuff) {
	return A2(
		_elm_lang$html$Html$li,
		{
			ctor: '::',
			_0: _user$project$IV_Pile_HtmlShorthand$role('presentation'),
			_1: {ctor: '[]'}
		},
		stuff);
};
var _user$project$IV_Pile_HtmlShorthand$navChoice = F3(
	function (label, onClick, isActive) {
		return A2(
			_elm_lang$html$Html$li,
			{
				ctor: '::',
				_0: _user$project$IV_Pile_HtmlShorthand$role('presentation'),
				_1: {
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$classList(
						{
							ctor: '::',
							_0: {ctor: '_Tuple2', _0: 'active', _1: isActive},
							_1: {ctor: '[]'}
						}),
					_1: {ctor: '[]'}
				}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$a,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$href('/iv'),
						_1: {
							ctor: '::',
							_0: _user$project$IV_Pile_HtmlShorthand$onClickWithoutPropagation(onClick),
							_1: {ctor: '[]'}
						}
					},
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text(label),
						_1: {ctor: '[]'}
					}),
				_1: {ctor: '[]'}
			});
	});
var _user$project$IV_Pile_HtmlShorthand$mailTo = A2(
	_elm_lang$html$Html$li,
	{
		ctor: '::',
		_0: _user$project$IV_Pile_HtmlShorthand$role('presentation'),
		_1: {ctor: '[]'}
	},
	{
		ctor: '::',
		_0: A2(
			_elm_lang$html$Html$a,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$href('mailto:marick@roundingpegs.com?subject=IV%20simulation'),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: _elm_lang$html$Html$text('Report a Problem'),
				_1: {ctor: '[]'}
			}),
		_1: {ctor: '[]'}
	});
var _user$project$IV_Pile_HtmlShorthand$row = F2(
	function (attrs, elements) {
		return A2(
			_elm_lang$html$Html$div,
			A2(
				_elm_lang$core$Basics_ops['++'],
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('row'),
					_1: {ctor: '[]'}
				},
				attrs),
			elements);
	});
var _user$project$IV_Pile_HtmlShorthand$rowSimple = function (string) {
	return A2(
		_user$project$IV_Pile_HtmlShorthand$row,
		{ctor: '[]'},
		{
			ctor: '::',
			_0: _elm_lang$html$Html$text(string),
			_1: {ctor: '[]'}
		});
};

var _user$project$IV_Version$source = 'https://github.com/marick/eecrit/tree/v541/web/elm/IV';
var _user$project$IV_Version$text = 'Version v541 of 2016-Nov-19';

var _user$project$IV_View_Layout$defaultFooterNav = {
	ctor: '::',
	_0: _user$project$IV_Pile_HtmlShorthand$navElement(
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$a,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$href('/iv/about'),
					_1: {
						ctor: '::',
						_0: _user$project$IV_Pile_HtmlShorthand$onClickWithoutPropagation(
							_user$project$IV_Msg$StartPageChange(_user$project$IV_Types$AboutPage)),
						_1: {ctor: '[]'}
					}
				},
				{
					ctor: '::',
					_0: _elm_lang$html$Html$text('About and Disclaimer'),
					_1: {ctor: '[]'}
				}),
			_1: {ctor: '[]'}
		}),
	_1: {
		ctor: '::',
		_0: _user$project$IV_Pile_HtmlShorthand$navElement(
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$a,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$href(_user$project$IV_Version$source),
						_1: {ctor: '[]'}
					},
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text(_user$project$IV_Version$text),
						_1: {ctor: '[]'}
					}),
				_1: {ctor: '[]'}
			}),
		_1: {ctor: '[]'}
	}
};
var _user$project$IV_View_Layout$footerWith = F2(
	function (prefix, navs) {
		return A2(
			_elm_lang$html$Html$footer,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class('footer'),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$hr,
					{ctor: '[]'},
					{ctor: '[]'}),
				_1: {
					ctor: '::',
					_0: prefix,
					_1: {
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$nav,
							{ctor: '[]'},
							{
								ctor: '::',
								_0: A2(
									_elm_lang$html$Html$ul,
									{
										ctor: '::',
										_0: _elm_lang$html$Html_Attributes$class('nav nav-pills pull-right'),
										_1: {ctor: '[]'}
									},
									navs),
								_1: {ctor: '[]'}
							}),
						_1: {ctor: '[]'}
					}
				}
			});
	});
var _user$project$IV_View_Layout$headerWith = function (navs) {
	return A2(
		_elm_lang$html$Html$div,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('header clearfix'),
			_1: {ctor: '[]'}
		},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$nav,
				{ctor: '[]'},
				{
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$ul,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class('nav nav-pills pull-right'),
							_1: {ctor: '[]'}
						},
						navs),
					_1: {ctor: '[]'}
				}),
			_1: {
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$h3,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('text-muted'),
						_1: {ctor: '[]'}
					},
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text('IV Worksheet'),
						_1: {ctor: '[]'}
					}),
				_1: {ctor: '[]'}
			}
		});
};

var _user$project$IV_Scenario_View$local = function (msg) {
	return _user$project$IV_Msg$ToScenario(msg);
};
var _user$project$IV_Scenario_View$changedText = F2(
	function (msg, string) {
		return _user$project$IV_Scenario_View$local(
			msg(string));
	});
var _user$project$IV_Scenario_View$unfinishedField = function (string) {
	var _p0 = _elm_lang$core$String$toFloat(string);
	if (_p0.ctor === 'Err') {
		return true;
	} else {
		return _elm_lang$core$Native_Utils.eq(_p0._0, 0.0);
	}
};
var _user$project$IV_Scenario_View$treatmentNeedsMoreUserWork = function (model) {
	return model.caseBackgroundEditorOpen || (_user$project$IV_Scenario_View$unfinishedField(model.decisions.dripRate) || (_user$project$IV_Scenario_View$unfinishedField(model.decisions.simulationHours) && _user$project$IV_Scenario_View$unfinishedField(model.decisions.simulationMinutes)));
};
var _user$project$IV_Scenario_View$description = function (model) {
	return A2(
		_elm_lang$core$Basics_ops['++'],
		'You are presented with ',
		A2(
			_elm_lang$core$Basics_ops['++'],
			model.background.animalDescription,
			A2(
				_elm_lang$core$Basics_ops['++'],
				'. You have ',
				A2(
					_elm_lang$core$Basics_ops['++'],
					model.background.bagContentsInLiters,
					A2(
						_elm_lang$core$Basics_ops['++'],
						' liters of fluid in a ',
						A2(
							_elm_lang$core$Basics_ops['++'],
							model.background.bagType,
							A2(
								_elm_lang$core$Basics_ops['++'],
								' that holds ',
								A2(_elm_lang$core$Basics_ops['++'], model.background.bagCapacityInLiters, ' liters.'))))))));
};
var _user$project$IV_Scenario_View$viewTreatmentEditor = function (model) {
	return A2(
		_user$project$IV_Pile_HtmlShorthand$row,
		{
			ctor: '::',
			_0: _user$project$IV_Pile_HtmlShorthand$greyableText(model.caseBackgroundEditorOpen),
			_1: {
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$style(
					{
						ctor: '::',
						_0: {ctor: '_Tuple2', _0: 'margin', _1: '0 1em 0 1em'},
						_1: {ctor: '[]'}
					}),
				_1: {ctor: '[]'}
			}
		},
		{
			ctor: '::',
			_0: _user$project$IV_Pile_HtmlShorthand$pSimple(
				_user$project$IV_Scenario_View$description(model)),
			_1: {
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$p,
					{ctor: '[]'},
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text('Using your calculations, set the drip rate to '),
						_1: {
							ctor: '::',
							_0: A3(
								_user$project$IV_Pile_HtmlShorthand$textInput,
								{
									ctor: '::',
									_0: _elm_lang$html$Html_Events$onBlur(
										_user$project$IV_Msg$ChoseDripRate(
											_user$project$IV_Scenario_DataExport$dripRate(model))),
									_1: {
										ctor: '::',
										_0: _elm_lang$html$Html_Attributes$disabled(model.caseBackgroundEditorOpen),
										_1: {ctor: '[]'}
									}
								},
								model.decisions.dripRate,
								_user$project$IV_Scenario_View$changedText(_user$project$IV_Scenario_Msg$ChangedDripText)),
							_1: {
								ctor: '::',
								_0: _elm_lang$html$Html$text('drops/sec, set the hours '),
								_1: {
									ctor: '::',
									_0: A3(
										_user$project$IV_Pile_HtmlShorthand$textInput,
										{
											ctor: '::',
											_0: _elm_lang$html$Html_Attributes$disabled(model.caseBackgroundEditorOpen),
											_1: {ctor: '[]'}
										},
										model.decisions.simulationHours,
										_user$project$IV_Scenario_View$changedText(_user$project$IV_Scenario_Msg$ChangedHoursText)),
									_1: {
										ctor: '::',
										_0: _elm_lang$html$Html$text(' and minutes '),
										_1: {
											ctor: '::',
											_0: A3(
												_user$project$IV_Pile_HtmlShorthand$textInput,
												{
													ctor: '::',
													_0: _elm_lang$html$Html_Attributes$disabled(model.caseBackgroundEditorOpen),
													_1: {ctor: '[]'}
												},
												model.decisions.simulationMinutes,
												_user$project$IV_Scenario_View$changedText(_user$project$IV_Scenario_Msg$ChangedMinutesText)),
											_1: {
												ctor: '::',
												_0: _elm_lang$html$Html$text(' until you plan to next look at the fluid level, then '),
												_1: {
													ctor: '::',
													_0: A3(
														_user$project$IV_Pile_HtmlShorthand$launchWhenDoneButton,
														_user$project$IV_Msg$StartSimulation(
															_user$project$IV_Scenario_DataExport$runnableModel(model)),
														_user$project$IV_Scenario_View$treatmentNeedsMoreUserWork(model),
														'Start the Clock'),
													_1: {ctor: '[]'}
												}
											}
										}
									}
								}
							}
						}
					}),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$p,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$style(
								{
									ctor: '::',
									_0: {ctor: '_Tuple2', _0: 'margin-top', _1: '2em'},
									_1: {ctor: '[]'}
								}),
							_1: {ctor: '[]'}
						},
						{
							ctor: '::',
							_0: _elm_lang$html$Html$text('If you don\'t like the result, '),
							_1: {
								ctor: '::',
								_0: A3(
									_user$project$IV_Pile_HtmlShorthand$launchWhenDoneButton,
									_user$project$IV_Msg$RestartScenario,
									_user$project$IV_Scenario_View$treatmentNeedsMoreUserWork(model),
									'Start Over'),
								_1: {ctor: '[]'}
							}
						}),
					_1: {ctor: '[]'}
				}
			}
		});
};
var _user$project$IV_Scenario_View$contentsTooBig = function (model) {
	var capacityText = model.background.bagCapacityInLiters;
	var contentsText = model.background.bagContentsInLiters;
	var val = function (field) {
		return A2(
			_elm_lang$core$Result$withDefault,
			0,
			_elm_lang$core$String$toFloat(field));
	};
	return (!_user$project$IV_Scenario_View$unfinishedField(capacityText)) && (_elm_lang$core$Native_Utils.cmp(
		val(contentsText),
		val(capacityText)) > 0);
};
var _user$project$IV_Scenario_View$backgroundNeedsMoreWork = function (model) {
	return _user$project$IV_Scenario_View$unfinishedField(model.background.bagCapacityInLiters) || (_user$project$IV_Scenario_View$unfinishedField(model.background.bagContentsInLiters) || (_user$project$IV_Scenario_View$unfinishedField(model.background.dropsPerMil) || _user$project$IV_Scenario_View$contentsTooBig(model)));
};
var _user$project$IV_Scenario_View$contentWarning = function (model) {
	var warning = _user$project$IV_Scenario_View$contentsTooBig(model) ? ' Content exceeds the capacity!' : '';
	return A2(
		_elm_lang$html$Html$span,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$style(
				{
					ctor: '::',
					_0: {ctor: '_Tuple2', _0: 'color', _1: 'red'},
					_1: {ctor: '[]'}
				}),
			_1: {ctor: '[]'}
		},
		{
			ctor: '::',
			_0: _elm_lang$html$Html$text(warning),
			_1: {ctor: '[]'}
		});
};
var _user$project$IV_Scenario_View$viewCaseBackgroundEditor = function (model) {
	return A2(
		_elm_lang$html$Html$div,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('row'),
			_1: {
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$style(
					{
						ctor: '::',
						_0: {ctor: '_Tuple2', _0: 'border', _1: '2px solid #AAA'},
						_1: {
							ctor: '::',
							_0: {ctor: '_Tuple2', _0: 'padding', _1: '2em'},
							_1: {
								ctor: '::',
								_0: {ctor: '_Tuple2', _0: 'margin-bottom', _1: '2em'},
								_1: {
									ctor: '::',
									_0: {ctor: '_Tuple2', _0: 'margin-left', _1: '3em'},
									_1: {
										ctor: '::',
										_0: {ctor: '_Tuple2', _0: 'margin-right', _1: '3em'},
										_1: {
											ctor: '::',
											_0: _user$project$IV_Pile_HtmlShorthand$displayStyle(model.caseBackgroundEditorOpen),
											_1: {ctor: '[]'}
										}
									}
								}
							}
						}
					}),
				_1: {ctor: '[]'}
			}
		},
		{
			ctor: '::',
			_0: _user$project$IV_Pile_HtmlShorthand$rowSimple('Set:'),
			_1: {
				ctor: '::',
				_0: A2(
					_user$project$IV_Pile_HtmlShorthand$row,
					{ctor: '[]'},
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text('... the container\'s '),
						_1: {
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$b,
								{ctor: '[]'},
								{
									ctor: '::',
									_0: _elm_lang$html$Html$text('capacity'),
									_1: {ctor: '[]'}
								}),
							_1: {
								ctor: '::',
								_0: _elm_lang$html$Html$text(' in liters '),
								_1: {
									ctor: '::',
									_0: A3(
										_user$project$IV_Pile_HtmlShorthand$textInput,
										{ctor: '[]'},
										model.background.bagCapacityInLiters,
										_user$project$IV_Scenario_View$changedText(_user$project$IV_Scenario_Msg$ChangedBagCapacity)),
									_1: {ctor: '[]'}
								}
							}
						}
					}),
				_1: {
					ctor: '::',
					_0: A2(
						_user$project$IV_Pile_HtmlShorthand$row,
						{ctor: '[]'},
						{
							ctor: '::',
							_0: _elm_lang$html$Html$text('... the container\'s '),
							_1: {
								ctor: '::',
								_0: A2(
									_elm_lang$html$Html$b,
									{ctor: '[]'},
									{
										ctor: '::',
										_0: _elm_lang$html$Html$text('starting contents'),
										_1: {ctor: '[]'}
									}),
								_1: {
									ctor: '::',
									_0: _elm_lang$html$Html$text(' in liters '),
									_1: {
										ctor: '::',
										_0: A3(
											_user$project$IV_Pile_HtmlShorthand$textInput,
											{ctor: '[]'},
											model.background.bagContentsInLiters,
											_user$project$IV_Scenario_View$changedText(_user$project$IV_Scenario_Msg$ChangedBagContents)),
										_1: {
											ctor: '::',
											_0: _user$project$IV_Scenario_View$contentWarning(model),
											_1: {ctor: '[]'}
										}
									}
								}
							}
						}),
					_1: {
						ctor: '::',
						_0: A2(
							_user$project$IV_Pile_HtmlShorthand$row,
							{ctor: '[]'},
							{
								ctor: '::',
								_0: _elm_lang$html$Html$text('... the number of drops per ml '),
								_1: {
									ctor: '::',
									_0: A3(
										_user$project$IV_Pile_HtmlShorthand$textInput,
										{ctor: '[]'},
										model.background.dropsPerMil,
										_user$project$IV_Scenario_View$changedText(_user$project$IV_Scenario_Msg$ChangedDropsPerMil)),
									_1: {ctor: '[]'}
								}
							}),
						_1: {
							ctor: '::',
							_0: _user$project$IV_Pile_HtmlShorthand$pSimple(' '),
							_1: {
								ctor: '::',
								_0: A2(
									_user$project$IV_Pile_HtmlShorthand$row,
									{
										ctor: '::',
										_0: _elm_lang$html$Html_Attributes$class('col-sm-12'),
										_1: {ctor: '[]'}
									},
									{
										ctor: '::',
										_0: A3(
											_user$project$IV_Pile_HtmlShorthand$launchWhenDoneButton,
											_user$project$IV_Msg$CloseCaseBackgroundEditor,
											_user$project$IV_Scenario_View$backgroundNeedsMoreWork(model),
											'Work With This'),
										_1: {ctor: '[]'}
									}),
								_1: {ctor: '[]'}
							}
						}
					}
				}
			}
		});
};
var _user$project$IV_Scenario_View$sameTags = F2(
	function (first, second) {
		return _elm_lang$core$Native_Utils.eq(
			_user$project$IV_Scenario_Lenses$model_tag.get(first),
			_user$project$IV_Scenario_Lenses$model_tag.get(second));
	});
var _user$project$IV_Scenario_View$editChoice = F2(
	function (possible, current) {
		return A3(
			_user$project$IV_Pile_HtmlShorthand$navChoice,
			_user$project$IV_Scenario_Lenses$model_tag.get(possible),
			_user$project$IV_Msg$OpenCaseBackgroundEditor,
			A2(_user$project$IV_Scenario_View$sameTags, possible, current));
	});
var _user$project$IV_Scenario_View$scenarioChoice = F2(
	function (possible, current) {
		return A3(
			_user$project$IV_Pile_HtmlShorthand$navChoice,
			_user$project$IV_Scenario_Lenses$model_tag.get(possible),
			_user$project$IV_Msg$PickedScenario(possible),
			A2(_user$project$IV_Scenario_View$sameTags, possible, current));
	});
var _user$project$IV_Scenario_View$viewScenarioChoices = function (model) {
	return {
		ctor: '::',
		_0: A2(
			_user$project$IV_Scenario_View$scenarioChoice,
			_user$project$IV_Scenario_Model$preparedScenario(_user$project$IV_Scenario_Model$cowBackground),
			model),
		_1: {
			ctor: '::',
			_0: A2(
				_user$project$IV_Scenario_View$scenarioChoice,
				_user$project$IV_Scenario_Model$preparedScenario(_user$project$IV_Scenario_Model$calfBackground),
				model),
			_1: {
				ctor: '::',
				_0: A2(
					_user$project$IV_Scenario_View$editChoice,
					_user$project$IV_Scenario_Model$preparedScenario(_user$project$IV_Scenario_Model$emptyBackground),
					model),
				_1: {
					ctor: '::',
					_0: _user$project$IV_Pile_HtmlShorthand$mailTo,
					_1: {ctor: '[]'}
				}
			}
		}
	};
};

var _user$project$IV_Apparatus_View$view = function (model) {
	return {
		ctor: '::',
		_0: _user$project$IV_Apparatus_DropletView$view(model.droplet),
		_1: {
			ctor: '::',
			_0: _user$project$IV_Apparatus_ChamberView$view(model.chamberFluid),
			_1: {
				ctor: '::',
				_0: _user$project$IV_Apparatus_BagView$view(model.bagLevel),
				_1: {
					ctor: '::',
					_0: _user$project$IV_Apparatus_HoseView$view(model.hoseFluid),
					_1: {ctor: '[]'}
				}
			}
		}
	};
};

var _user$project$IV_View_MainPage$aboutThisBrowser = function () {
	var letMeKnow = A2(
		_elm_lang$html$Html$a,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$type_('button'),
			_1: {
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class('btn btn-default btn-xs'),
				_1: {
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$href('mailto:marick@roundingpegs.com?subject=Browser%20report'),
					_1: {ctor: '[]'}
				}
			}
		},
		{
			ctor: '::',
			_0: _elm_lang$html$Html$text('let me know'),
			_1: {ctor: '[]'}
		});
	var $default = {
		ctor: '::',
		_0: _elm_lang$html$Html$text('Note: I don\'t know if the drawing or animation '),
		_1: {
			ctor: '::',
			_0: _elm_lang$html$Html$text('will work on your browser. If it does, '),
			_1: {
				ctor: '::',
				_0: letMeKnow,
				_1: {ctor: '[]'}
			}
		}
	};
	var body = function () {
		var _p0 = _coreytrampe$elm_vendor$Vendor$prefix;
		switch (_p0.ctor) {
			case 'Webkit':
				return {
					ctor: '::',
					_0: _elm_lang$html$Html$text('Note: '),
					_1: {
						ctor: '::',
						_0: _elm_lang$html$Html$text('This app\'s animation is known to work on the latest version of your browser. '),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html$text('If you are having problems, you can try upgrading.'),
							_1: {ctor: '[]'}
						}
					}
				};
			case 'Moz':
				return {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$span,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$style(
								{
									ctor: '::',
									_0: {ctor: '_Tuple2', _0: 'color', _1: 'red'},
									_1: {ctor: '[]'}
								}),
							_1: {ctor: '[]'}
						},
						{
							ctor: '::',
							_0: _elm_lang$html$Html$text('This app\'s drawing and animation is known '),
							_1: {
								ctor: '::',
								_0: A2(
									_elm_lang$html$Html$b,
									{ctor: '[]'},
									{
										ctor: '::',
										_0: _elm_lang$html$Html$text('not'),
										_1: {ctor: '[]'}
									}),
								_1: {
									ctor: '::',
									_0: _elm_lang$html$Html$text(' to work on the Macintosh version of Firefox, and it '),
									_1: {
										ctor: '::',
										_0: _elm_lang$html$Html$text(' probably doesn\'t work on any version. If it '),
										_1: {
											ctor: '::',
											_0: A2(
												_elm_lang$html$Html$b,
												{ctor: '[]'},
												{
													ctor: '::',
													_0: _elm_lang$html$Html$text('does'),
													_1: {ctor: '[]'}
												}),
											_1: {
												ctor: '::',
												_0: _elm_lang$html$Html$text(' work, '),
												_1: {
													ctor: '::',
													_0: letMeKnow,
													_1: {ctor: '[]'}
												}
											}
										}
									}
								}
							}
						}),
					_1: {ctor: '[]'}
				};
			case 'MS':
				return {
					ctor: '::',
					_0: _elm_lang$html$Html$text('Note: I don\'t have a Windows computer, so I don\'t know if '),
					_1: {
						ctor: '::',
						_0: _elm_lang$html$Html$text('this will work with your browser. If it does, '),
						_1: {
							ctor: '::',
							_0: letMeKnow,
							_1: {ctor: '[]'}
						}
					}
				};
			default:
				return $default;
		}
	}();
	return A2(
		_user$project$IV_Pile_HtmlShorthand$row,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('col-sm-12'),
			_1: {ctor: '[]'}
		},
		body);
}();
var _user$project$IV_View_MainPage$graphics = {width: '400px', height: '400px'};
var _user$project$IV_View_MainPage$mainSvg = function (contents) {
	return A2(
		_user$project$IV_Pile_HtmlShorthand$row,
		{ctor: '[]'},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$svg$Svg$svg,
				{
					ctor: '::',
					_0: _elm_lang$svg$Svg_Attributes$version('1.1'),
					_1: {
						ctor: '::',
						_0: _elm_lang$svg$Svg_Attributes$x('0'),
						_1: {
							ctor: '::',
							_0: _elm_lang$svg$Svg_Attributes$y('0'),
							_1: {
								ctor: '::',
								_0: _elm_lang$svg$Svg_Attributes$width(_user$project$IV_View_MainPage$graphics.width),
								_1: {
									ctor: '::',
									_0: _elm_lang$svg$Svg_Attributes$height(_user$project$IV_View_MainPage$graphics.height),
									_1: {ctor: '[]'}
								}
							}
						}
					}
				},
				contents),
			_1: {ctor: '[]'}
		});
};
var _user$project$IV_View_MainPage$view = function (model) {
	return A2(
		_elm_lang$html$Html$div,
		{ctor: '[]'},
		{
			ctor: '::',
			_0: _user$project$IV_View_Layout$headerWith(
				_user$project$IV_Scenario_View$viewScenarioChoices(model.scenario)),
			_1: {
				ctor: '::',
				_0: _user$project$IV_Scenario_View$viewCaseBackgroundEditor(model.scenario),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$div,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class('row'),
							_1: {ctor: '[]'}
						},
						{
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$div,
								{
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$class('col-sm-6'),
									_1: {ctor: '[]'}
								},
								{
									ctor: '::',
									_0: _user$project$IV_View_MainPage$mainSvg(
										A2(
											_elm_lang$core$Basics_ops['++'],
											_user$project$IV_Apparatus_View$view(model.apparatus),
											_user$project$IV_Clock_View$view(model.clock))),
									_1: {ctor: '[]'}
								}),
							_1: {
								ctor: '::',
								_0: A2(
									_elm_lang$html$Html$div,
									{
										ctor: '::',
										_0: _elm_lang$html$Html_Attributes$class('col-sm-6'),
										_1: {ctor: '[]'}
									},
									{
										ctor: '::',
										_0: _user$project$IV_Scenario_View$viewTreatmentEditor(model.scenario),
										_1: {ctor: '[]'}
									}),
								_1: {ctor: '[]'}
							}
						}),
					_1: {
						ctor: '::',
						_0: A2(_user$project$IV_View_Layout$footerWith, _user$project$IV_View_MainPage$aboutThisBrowser, _user$project$IV_View_Layout$defaultFooterNav),
						_1: {ctor: '[]'}
					}
				}
			}
		});
};

var _user$project$IV_View_AboutPage$view = A2(
	_user$project$IV_Pile_HtmlShorthand$row,
	{ctor: '[]'},
	{
		ctor: '::',
		_0: _user$project$IV_View_Layout$headerWith(
			{
				ctor: '::',
				_0: _user$project$IV_Pile_HtmlShorthand$navElement(
					{
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$a,
							{
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$href('/iv'),
								_1: {
									ctor: '::',
									_0: _user$project$IV_Pile_HtmlShorthand$onClickWithoutPropagation(
										_user$project$IV_Msg$StartPageChange(_user$project$IV_Types$MainPage)),
									_1: {ctor: '[]'}
								}
							},
							{
								ctor: '::',
								_0: _elm_lang$html$Html$text('Back to the App'),
								_1: {ctor: '[]'}
							}),
						_1: {ctor: '[]'}
					}),
				_1: {ctor: '[]'}
			}),
		_1: {
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$p,
				{ctor: '[]'},
				{
					ctor: '::',
					_0: _elm_lang$html$Html$text('\n                This application is intended to be used by teachers and students.\n                Any use of it in real medical situations is\n                '),
					_1: {
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$strong,
							{ctor: '[]'},
							{
								ctor: '::',
								_0: _elm_lang$html$Html$text('at your own risk'),
								_1: {ctor: '[]'}
							}),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html$text('. (See the scary legal boilerplate below.)'),
							_1: {ctor: '[]'}
						}
					}
				}),
			_1: {
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$p,
					{ctor: '[]'},
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text('The app is written in the '),
						_1: {
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$a,
								{
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$href('http://elm-lang.org'),
									_1: {ctor: '[]'}
								},
								{
									ctor: '::',
									_0: _elm_lang$html$Html$text('Elm programming language'),
									_1: {ctor: '[]'}
								}),
							_1: {
								ctor: '::',
								_0: _elm_lang$html$Html$text(' and the source is '),
								_1: {
									ctor: '::',
									_0: A2(
										_elm_lang$html$Html$a,
										{
											ctor: '::',
											_0: _elm_lang$html$Html_Attributes$href('https://github.com/marick/eecrit/tree/master/web/elm/IV'),
											_1: {ctor: '[]'}
										},
										{
											ctor: '::',
											_0: _elm_lang$html$Html$text('freely available'),
											_1: {ctor: '[]'}
										}),
									_1: {
										ctor: '::',
										_0: _elm_lang$html$Html$text(' under the '),
										_1: {
											ctor: '::',
											_0: A2(
												_elm_lang$html$Html$a,
												{
													ctor: '::',
													_0: _elm_lang$html$Html_Attributes$href('https://en.wikipedia.org/wiki/MIT_License'),
													_1: {ctor: '[]'}
												},
												{
													ctor: '::',
													_0: _elm_lang$html$Html$text('MIT License'),
													_1: {ctor: '[]'}
												}),
											_1: {
												ctor: '::',
												_0: _elm_lang$html$Html$text('.'),
												_1: {ctor: '[]'}
											}
										}
									}
								}
							}
						}
					}),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$hr,
						{ctor: '[]'},
						{ctor: '[]'}),
					_1: {
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$p,
							{ctor: '[]'},
							{
								ctor: '::',
								_0: _elm_lang$html$Html$text('Copyright © 2016 Brian Marick'),
								_1: {ctor: '[]'}
							}),
						_1: {
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$p,
								{ctor: '[]'},
								{
									ctor: '::',
									_0: _elm_lang$html$Html$text('\n                THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND,\n                EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES\n                OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND\n                NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT\n                HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,\n                WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING\n                FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR\n                OTHER DEALINGS IN THE SOFTWARE.\n                '),
									_1: {ctor: '[]'}
								}),
							_1: {
								ctor: '::',
								_0: A2(
									_user$project$IV_View_Layout$footerWith,
									A2(
										_elm_lang$html$Html$span,
										{ctor: '[]'},
										{ctor: '[]'}),
									_user$project$IV_View_Layout$defaultFooterNav),
								_1: {ctor: '[]'}
							}
						}
					}
				}
			}
		}
	});

var _user$project$IV_View$view = function (model) {
	var _p0 = model.page;
	if (_p0.ctor === 'MainPage') {
		return _user$project$IV_View_MainPage$view(model);
	} else {
		return _user$project$IV_View_AboutPage$view;
	}
};

var _user$project$IV$main = A2(
	_elm_lang$navigation$Navigation$program,
	_user$project$IV_Msg$NoticePageChange,
	{init: _user$project$IV_Main$init, view: _user$project$IV_View$view, update: _user$project$IV_Main$update, subscriptions: _user$project$IV_Main$subscriptions})();

var Elm = {};
Elm['Animals'] = Elm['Animals'] || {};
if (typeof _user$project$Animals$main !== 'undefined') {
    _user$project$Animals$main(Elm['Animals'], 'Animals', undefined);
}
Elm['IV'] = Elm['IV'] || {};
if (typeof _user$project$IV$main !== 'undefined') {
    _user$project$IV$main(Elm['IV'], 'IV', undefined);
}

if (typeof define === "function" && define['amd'])
{
  define([], function() { return Elm; });
  return;
}

if (typeof module === "object")
{
  module['exports'] = Elm;
  return;
}

var globalElm = this['Elm'];
if (typeof globalElm === "undefined")
{
  this['Elm'] = Elm;
  return;
}

for (var publicModule in Elm)
{
  if (publicModule in globalElm)
  {
    throw new Error('There are two Elm modules called `' + publicModule + '` on this page! Rename one of them.');
  }
  globalElm[publicModule] = Elm[publicModule];
}

}).call(this);

