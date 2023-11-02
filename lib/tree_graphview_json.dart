import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';

class TreeViewPageFromJson extends StatefulWidget {
  @override
  _TreeViewPageFromJsonState createState() => _TreeViewPageFromJsonState();
}

class _TreeViewPageFromJsonState extends State<TreeViewPageFromJson> {
  var json = {
    'nodes': [
      {'id': 1, 'label': '평행선 사이의 선분의 길이의 비', 'isCompleted': 'true'},
      {'id': 2, 'label': '삼각형에서 평행선 사이 선분의 길이의 비'},
      {'id': 3, 'label': '삼각형의 각의 이등분선', 'isCompleted': 'true'},
      {'id': 4, 'label': 'box'},
      {'id': 5, 'label': 'diamond', 'isCompleted': 'true'},
      {'id': 6, 'label': 'dot', 'isCompleted': 'true'},
      {'id': 7, 'label': 'square', 'isCompleted': 'true'},
      {'id': 8, 'label': 'triangle'},
    ],
    'edges': [
      {'from': 1, 'to': 2},
      {'from': 2, 'to': 3},
      {'from': 2, 'to': 4},
      {'from': 2, 'to': 5},
      {'from': 5, 'to': 6},
      {'from': 5, 'to': 7},
      {'from': 6, 'to': 8}
    ]
  };

  final List<GlobalKey> _containerKey = List.generate(9, (index) => GlobalKey());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Wrap(
              children: [
                Container(
                  width: 100,
                  child: TextFormField(
                    initialValue: builder.siblingSeparation.toString(),
                    decoration: InputDecoration(labelText: 'Sibling Separation'),
                    onChanged: (text) {
                      builder.siblingSeparation = int.tryParse(text) ?? 100;
                      setState(() {});
                    },
                  ),
                ),
                Container(
                  width: 100,
                  child: TextFormField(
                    initialValue: builder.levelSeparation.toString(),
                    decoration: InputDecoration(labelText: 'Level Separation'),
                    onChanged: (text) {
                      builder.levelSeparation = int.tryParse(text) ?? 100;
                      setState(() {});
                    },
                  ),
                ),
                Container(
                  width: 100,
                  child: TextFormField(
                    initialValue: builder.subtreeSeparation.toString(),
                    decoration: InputDecoration(labelText: 'Subtree separation'),
                    onChanged: (text) {
                      builder.subtreeSeparation = int.tryParse(text) ?? 100;
                      setState(() {});
                    },
                  ),
                ),
                Container(
                  width: 100,
                  child: TextFormField(
                    initialValue: builder.orientation.toString(),
                    decoration: InputDecoration(labelText: 'Orientation'),
                    onChanged: (text) {
                      builder.orientation = int.tryParse(text) ?? 100;
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            Expanded(
              child: InteractiveViewer(
                  constrained: false,
                  boundaryMargin: EdgeInsets.all(100),
                  minScale: 0.01,
                  maxScale: 5.6,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: GraphView(
                      graph: graph,
                      algorithm: BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
                      paint: Paint()
                        ..color = Colors.green
                        ..strokeWidth = 1
                        ..style = PaintingStyle.stroke,
                      builder: (Node node) {
                        // I can decide what widget should be shown here based on the id
                        print(node.key!.value);
                        var a = node.key!.value as int?;
                        var nodes = json['nodes']!;
                        var nodeValue = nodes.firstWhere((element) => element['id'] == a);
                        return rectangleWidget(node.key!.value, nodeValue['label'] as String?, nodeValue['isCompleted'] as String?);
                      },
                    ),
                  )),
            ),
          ],
        ));
  }

  Widget rectangleWidget(int index, String? a, String? isCompleted) {
    bool completed = isCompleted != null && isCompleted == 'true' ? true : false;

    return InkWell(
      onTap: () {
        print('$a: ${_getOffset(index)}');
        Scrollable.ensureVisible(
          _containerKey[index].currentContext!
        );
      },
      child: Container(
        key: _containerKey[index],
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(color: completed ? Colors.green : Colors.blue[100]!, spreadRadius: 1),
            ],
          ),
          child: Text('${a}')),
    );
  }

  Offset? _getOffset(int index) {
    if (_containerKey[index].currentContext != null) {
      final RenderBox renderBox =
      _containerKey[index].currentContext!.findRenderObject() as RenderBox;
      Offset offset = renderBox.localToGlobal(Offset.zero);
      return offset;
    }
  }

  final Graph graph = Graph()..isTree = true;
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  @override
  void initState() {
    var edges = json['edges']!;
    edges.forEach((element) {
      var fromNodeId = element['from'];
      var toNodeId = element['to'];
      graph.addEdge(Node.Id(fromNodeId), Node.Id(toNodeId));
    });

    builder
      ..siblingSeparation = (100)
      ..levelSeparation = (150)
      ..subtreeSeparation = (150)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT);
  }
}
