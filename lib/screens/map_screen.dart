import 'package:flutter/material.dart';
import 'dart:math' as math;

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

// Define a grid item model to track multi-cell items
class GridItem {
  final String type;
  final int width;
  final int height;
  double rotation; // in radians

  GridItem({
    required this.type,
    required this.width,
    required this.height,
    this.rotation = 0.0,
  });

  // Create a copy of the item with new rotation
  GridItem copyWith({double? rotation}) {
    return GridItem(
      type: this.type,
      width: this.width,
      height: this.height,
      rotation: rotation ?? this.rotation,
    );
  }
}

// Object to store on our grid matrix
class PlacedItem {
  final String type;
  final GridItem definition;
  final int row;
  final int col;
  double rotation;

  PlacedItem({
    required this.type,
    required this.definition,
    required this.row,
    required this.col,
    this.rotation = 0.0,
  });
}

class _MapScreenState extends State<MapScreen> {
  String? _selectedItem;
  final int _gridSize = 30; // Larger grid for more detail
  final Map<String, GridItem> _itemDefinitions = {
    'Road': GridItem(type: 'Road', width: 8, height: 5, rotation: 0.0),
    'Intersection': GridItem(type: 'Intersection', width: 5, height: 5),
    'Traffic Light': GridItem(type: 'Traffic Light', width: 2, height: 2),
    'Building': GridItem(type: 'Building', width: 4, height: 4),
    'Stop Sign': GridItem(type: 'Stop Sign', width: 1, height: 1),
    'Pedestrian': GridItem(type: 'Pedestrian', width: 1, height: 1),
    'Car': GridItem(type: 'Car', width: 2, height: 1),
  };

  // Matrix to store item references instead of absolute positions
  // Each cell in the matrix will contain either null or a reference to a placed item
  late List<List<PlacedItem?>> _gridMatrix;

  // List of all placed items
  final List<PlacedItem> _placedItems = [];
  PlacedItem? _selectedPlacedItem;

  @override
  void initState() {
    super.initState();
    // Initialize the grid matrix with nulls
    _initializeGridMatrix();
  }

  void _initializeGridMatrix() {
    _gridMatrix = List.generate(
        _gridSize,
            (_) => List.generate(_gridSize, (_) => null)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Map area with grid
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Traffic Simulation Map',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _selectedPlacedItem != null ? _removeSelectedItem : null,
                          child: const Text('Remove Selected'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _buildMapGrid(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom panel with street elements
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                      child: Text(
                        'Street Elements',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildDraggableElement('Road', 'assets/images/road.png'),
                          _buildDraggableElement('Intersection', 'assets/images/intersection.png'),
                          _buildDraggableElement('Traffic Light', Icons.traffic),
                          _buildDraggableElement('Building', Icons.home),
                          _buildDraggableElement('Stop Sign', Icons.stop_circle),
                          _buildDraggableElement('Pedestrian', Icons.directions_walk),
                          _buildDraggableElement('Car', Icons.directions_car),
                          if (_selectedPlacedItem != null && _selectedPlacedItem!.type == 'Road')
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text('Rotate', style: TextStyle(fontSize: 12)),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.rotate_left, size: 24),
                                              onPressed: () => _rotateSelectedItem(-math.pi/2),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.rotate_right, size: 24),
                                              onPressed: () => _rotateSelectedItem(math.pi/2),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableElement(String name, dynamic iconOrImage) {
    final GridItem definition = _itemDefinitions[name]!;

    return Card(
      child: Draggable<Map<String, dynamic>>(
        data: {'type': name, 'definition': definition},
        feedback: Container(
          width: 60.0, // Fixed size for feedback
          height: 60.0,
          decoration: BoxDecoration(
            color: _getItemColor(name).withOpacity(0.7),
            border: Border.all(color: Colors.blue, width: 2),
          ),
          child: Center(
            child: iconOrImage is IconData
                ? Icon(iconOrImage, size: 24, color: Colors.white)
                : Image.asset(iconOrImage, fit: BoxFit.contain),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.5,
          child: _buildElementCard(name, iconOrImage),
        ),
        child: _buildElementCard(name, iconOrImage),
      ),
    );
  }

  Widget _buildElementCard(String name, dynamic iconOrImage) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconOrImage is IconData
              ? Icon(iconOrImage, size: 32, color: Colors.grey.shade700)
              : Image.asset(iconOrImage, width: 32, height: 32),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _rotateSelectedItem(double angle) {
    if (_selectedPlacedItem != null && _selectedPlacedItem!.type == 'Road') {
      setState(() {
        // Update rotation in the matrix
        _removeItemFromMatrix(_selectedPlacedItem!);
        _selectedPlacedItem!.rotation = (_selectedPlacedItem!.rotation + angle) % (math.pi * 2);
        _addItemToMatrix(_selectedPlacedItem!);
      });
    }
  }

  void _removeSelectedItem() {
    if (_selectedPlacedItem != null) {
      setState(() {
        // Remove from matrix
        _removeItemFromMatrix(_selectedPlacedItem!);
        // Remove from placed items list
        _placedItems.remove(_selectedPlacedItem);
        _selectedPlacedItem = null;
      });
    }
  }

  // Removes an item from the matrix
  void _removeItemFromMatrix(PlacedItem item) {
    final int itemRow = item.row;
    final int itemCol = item.col;
    final int itemWidth = item.definition.width;
    final int itemHeight = item.definition.height;

    // Clear the cells in the matrix that this item occupies
    for (int r = itemRow; r < itemRow + itemHeight; r++) {
      for (int c = itemCol; c < itemCol + itemWidth; c++) {
        if (r < _gridSize && c < _gridSize) {
          _gridMatrix[r][c] = null;
        }
      }
    }
  }

  // Add an item to the matrix
  void _addItemToMatrix(PlacedItem item) {
    final int itemRow = item.row;
    final int itemCol = item.col;
    final int itemWidth = item.definition.width;
    final int itemHeight = item.definition.height;

    // Set references to this item in all cells it occupies
    for (int r = itemRow; r < itemRow + itemHeight; r++) {
      for (int c = itemCol; c < itemCol + itemWidth; c++) {
        if (r < _gridSize && c < _gridSize) {
          _gridMatrix[r][c] = item;
        }
      }
    }
  }

  Widget _buildMapGrid() {
    return GridView.builder(
      physics: const ClampingScrollPhysics(), // Allow scrolling but keep it inside bounds
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _gridSize,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: _gridSize * _gridSize,
      itemBuilder: (context, index) {
        final row = index ~/ _gridSize;
        final col = index % _gridSize;
        return _buildGridCell(row, col);
      },
    );
  }

  Widget _buildGridCell(int row, int col) {
    // Get the item at this cell position from our matrix
    PlacedItem? cellItem = _gridMatrix[row][col];

    return DragTarget<Map<String, dynamic>>(
      onAccept: (data) {
        // Check if this is a drag from the palette or a move of existing item
        final String itemType = data['type'];
        final GridItem definition = data['definition'];

        // If there's an item index, it's a move operation
        if (data.containsKey('itemIndex')) {
          final int itemIndex = data['itemIndex'];
          final PlacedItem item = _placedItems[itemIndex];

          // Only move if we can place the item at the new position
          if (_canPlaceItem(row, col, definition, excludeItem: item)) {
            setState(() {
              // Remove from old position
              _removeItemFromMatrix(item);

              // Update position
              final PlacedItem updatedItem = PlacedItem(
                type: item.type,
                definition: item.definition,
                row: row,
                col: col,
                rotation: item.rotation,
              );

              // Replace in the list
              _placedItems[itemIndex] = updatedItem;

              // Add to new position in matrix
              _addItemToMatrix(updatedItem);

              // Update selected item if needed
              if (_selectedPlacedItem == item) {
                _selectedPlacedItem = updatedItem;
              }
            });
          }
        } else {
          // New item placement
          if (_canPlaceItem(row, col, definition)) {
            setState(() {
              final PlacedItem newItem = PlacedItem(
                type: itemType,
                definition: definition,
                row: row,
                col: col,
                rotation: 0.0,
              );

              _placedItems.add(newItem);
              _addItemToMatrix(newItem);
              _selectedPlacedItem = newItem;
            });
          }
        }
      },
      builder: (context, candidateData, rejectedData) {
        // If this cell has an item AND it's the top-left of the item
        if (cellItem != null && cellItem.row == row && cellItem.col == col) {
          // This is the top-left cell of an item, render the full item here
          bool isSelected = _selectedPlacedItem == cellItem;

          return Draggable<Map<String, dynamic>>(
            data: {
              'type': cellItem.type,
              'definition': cellItem.definition,
              'itemIndex': _placedItems.indexOf(cellItem),
            },
            feedback: Transform.rotate(
              angle: cellItem.rotation,
              child: Container(
                width: 60.0, // Fixed feedback size
                height: 60.0,
                decoration: BoxDecoration(
                  color: _getItemColor(cellItem.type),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.black,
                    width: isSelected ? 2.0 : 1.0,
                  ),
                ),
                child: cellItem.type == 'Road' || cellItem.type == 'Intersection'
                    ? Image.asset(
                        cellItem.type == 'Road'
                            ? 'assets/images/road.png'
                            : 'assets/images/intersection.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    : _getIconForItem(cellItem.type),
              ),
            ),
            childWhenDragging: Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                border: Border.all(color: Colors.grey),
              ),
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPlacedItem = isSelected ? null : cellItem;
                });
              },
              child: Transform.rotate(
                angle: cellItem.rotation,
                child: Container(
                  decoration: BoxDecoration(
                    color: _getItemColor(cellItem.type),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.black,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                  ),
                  child: cellItem.type == 'Road' || cellItem.type == 'Intersection'
                      ? Image.asset(
                          cellItem.type == 'Road'
                              ? 'assets/images/road.png'
                              : 'assets/images/intersection.png',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        )
                      : _getIconForItem(cellItem.type),
                ),
              ),
            ),
          );
        } else if (cellItem != null) {
          // This cell is part of an item but not the top-left, render just color
          return Container(
            color: Colors.transparent, // Make this cell transparent
          );
        } else {
          // Empty cell
          final bool isValidDrop = candidateData.isNotEmpty &&
              _canPlaceItem(
                  row,
                  col,
                  candidateData.first?['definition'],
                  excludeItem: candidateData.first!.containsKey('itemIndex') ?
                  _placedItems[candidateData.first?['itemIndex']] : null
              );

          return Container(
            decoration: BoxDecoration(
              color: candidateData.isNotEmpty
                  ? (isValidDrop
                  ? Colors.green.withOpacity(0.3)  // Valid placement
                  : Colors.red.withOpacity(0.3))   // Invalid placement
                  : Colors.grey.withOpacity(0.05),   // Empty cell
              border: Border.all(
                color: Colors.grey.shade300,
                width: 0.5,
              ),
            ),
          );
        }
      },
    );
  }

  bool _canPlaceItem(int row, int col, GridItem definition, {PlacedItem? excludeItem}) {
    // First, check if the item would go out of bounds
    if (row < 0 || col < 0 ||
        row + definition.height > _gridSize ||
        col + definition.width > _gridSize) {
      return false;
    }

    // For each cell the item would occupy, check if it's already taken
    for (int r = row; r < row + definition.height; r++) {
      for (int c = col; c < col + definition.width; c++) {
        // Out of bounds check (redundant but safe)
        if (r >= _gridSize || c >= _gridSize) return false;

        // Check if the cell is occupied by a different item
        final PlacedItem? occupyingItem = _gridMatrix[r][c];
        if (occupyingItem != null && occupyingItem != excludeItem) {
          return false;
        }
      }
    }

    return true;
  }

  Color _getItemColor(String itemType) {
    switch (itemType) {
      case 'Road': return Colors.grey.shade400;
      case 'Intersection': return Colors.grey.shade600;
      case 'Traffic Light': return Colors.red.shade100;
      case 'Building': return Colors.brown.shade100;
      case 'Stop Sign': return Colors.red.shade100;
      case 'Pedestrian': return Colors.blue.shade100;
      case 'Car': return Colors.green.shade100;
      default: return Colors.white;
    }
  }

  Widget _getIconForItem(String itemType) {
    switch (itemType) {
      case 'Traffic Light': return Icon(Icons.traffic, color: Colors.red);
      case 'Building': return Icon(Icons.home, color: Colors.brown);
      case 'Stop Sign': return Icon(Icons.stop_circle, color: Colors.red);
      case 'Pedestrian': return Icon(Icons.directions_walk, color: Colors.blue);
      case 'Car': return Icon(Icons.directions_car, color: Colors.green);
      default: return const SizedBox.shrink();
    }
  }
}