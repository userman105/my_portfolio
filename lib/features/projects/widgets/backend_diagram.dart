import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Visual stand-in for the screenshot carousel on backend-only projects.
///
/// Two views, switched with the pill at the top:
///  • Architecture – services as nodes, with packets flowing along each link.
///    Accent colour = REST over HTTP, cyan = real-time over WebSocket.
///  • Data model   – the five tables and how they relate.
///
/// Drop-in replacement for [ProjectCarousel]: same `accentColor` and `height`.
class BackendDiagram extends StatefulWidget {
  final Color accentColor;
  final double height;

  const BackendDiagram({
    super.key,
    required this.accentColor,
    this.height = 640,
  });

  @override
  State<BackendDiagram> createState() => _BackendDiagramState();
}

class _BackendDiagramState extends State<BackendDiagram>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flow = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  )..repeat();

  int _view = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respect the OS "reduce motion" setting: show the links, skip the packets.
    if (MediaQuery.of(context).disableAnimations) {
      _flow.stop();
    } else if (!_flow.isAnimating) {
      _flow.repeat();
    }
  }

  @override
  void dispose() {
    _flow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Column(
        children: [
          _ViewSwitch(
            index: _view,
            labels: const ['Architecture', 'Data model'],
            accent: widget.accentColor,
            onChanged: (i) => setState(() => _view = i),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _view == 0
                  ? _ArchitectureView(
                      key: const ValueKey('architecture'),
                      flow: _flow,
                      accent: widget.accentColor,
                    )
                  : _DataModelView(
                      key: const ValueKey('data'),
                      accent: widget.accentColor,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Shared pieces
// ─────────────────────────────────────────────────────────────

const Color _wsColor = Color(0xFF67E8F9); // real-time traffic

class _Node {
  final String title;
  final String sub;
  final String tip;
  final IconData icon;
  final Offset center;
  final Color color;
  const _Node(this.title, this.sub, this.tip, this.icon, this.center, this.color);
}

class _Link {
  final Offset a;
  final Offset b;
  final Color color;
  final bool flow; // animate packets along it
  final bool both; // packets travel both ways
  final double phase;
  final String? label;
  const _Link(
    this.a,
    this.b,
    this.color, {
    this.flow = true,
    this.both = false,
    this.phase = 0,
    this.label,
  });
}

/// Point where the line from [c] toward [toward] leaves the node's box.
Offset _anchor(Offset c, Size box, Offset toward) {
  final d = toward - c;
  if (d == Offset.zero) return c;
  final sx = d.dx == 0 ? double.infinity : (box.width / 2) / d.dx.abs();
  final sy = d.dy == 0 ? double.infinity : (box.height / 2) / d.dy.abs();
  final s = math.min(sx, sy);
  return c + d * s + d / d.distance * 5; // 5px breathing room
}

_Link _link(
  _Node from,
  _Node to,
  Size box,
  Color color, {
  bool flow = true,
  bool both = false,
  double phase = 0,
  String? label,
}) {
  return _Link(
    _anchor(from.center, box, to.center),
    _anchor(to.center, box, from.center),
    color,
    flow: flow,
    both: both,
    phase: phase,
    label: label,
  );
}

class _LinkPainter extends CustomPainter {
  final List<_Link> links;
  final Animation<double>? t;

  _LinkPainter(this.links, this.t) : super(repaint: t);

  @override
  void paint(Canvas canvas, Size size) {
    final anim = t;
    for (final l in links) {
      canvas.drawLine(
        l.a,
        l.b,
        Paint()
          ..color = l.color.withOpacity(l.flow ? 0.28 : 0.5)
          ..strokeWidth = 1.4
          ..strokeCap = StrokeCap.round,
      );

      if (!l.flow || anim == null) continue;

      const packets = 2;
      for (var k = 0; k < packets; k++) {
        final p = (anim.value + l.phase + k / packets) % 1.0;
        final back = l.both && k.isOdd;
        final pos = Offset.lerp(back ? l.b : l.a, back ? l.a : l.b, p)!;
        final fade = math.sin(p * math.pi); // fade in/out at the ends

        canvas.drawCircle(
          pos,
          8,
          Paint()
            ..color = l.color.withOpacity(0.45 * fade)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
        canvas.drawCircle(
          pos,
          3.2,
          Paint()..color = l.color.withOpacity(0.35 + 0.65 * fade),
        );
        canvas.drawCircle(
          pos,
          1.4,
          Paint()..color = Colors.white.withOpacity(0.9 * fade),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LinkPainter old) => true;
}

class _NodeCard extends StatelessWidget {
  final _Node node;
  final Size size;
  const _NodeCard({required this.node, required this.size});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: node.center.dx - size.width / 2,
      top: node.center.dy - size.height / 2,
      width: size.width,
      height: size.height,
      child: Tooltip(
        message: node.tip,
        waitDuration: const Duration(milliseconds: 300),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                node.color.withOpacity(0.38),
                node.color.withOpacity(0.14),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.38), width: 0.6),
            boxShadow: [
              BoxShadow(
                color: node.color.withOpacity(0.30),
                blurRadius: 18,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(node.icon, size: 20, color: Colors.white.withOpacity(0.92)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      node.sub,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.5,
                        height: 1.25,
                        color: Colors.white.withOpacity(0.65),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinkLabel extends StatelessWidget {
  final _Link link;
  const _LinkLabel({required this.link});

  @override
  Widget build(BuildContext context) {
    final mid = Offset.lerp(link.a, link.b, 0.5)!;
    return Positioned(
      left: mid.dx,
      top: mid.dy,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF021B4D).withOpacity(0.55),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: link.color.withOpacity(0.55), width: 0.5),
          ),
          child: Text(
            link.label!,
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 0.3,
              color: Colors.white.withOpacity(0.88),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  View 1 – Architecture
// ─────────────────────────────────────────────────────────────

class _ArchitectureView extends StatelessWidget {
  final Animation<double> flow;
  final Color accent;
  const _ArchitectureView({super.key, required this.flow, required this.accent});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final h = c.maxHeight;
      final box = Size(math.min(156.0, w * 0.40), 66);
      Offset at(double fx, double fy) => Offset(w * fx, h * fy);

      final client = _Node(
        'Chat client',
        'App or browser',
        'Signs in over REST, then keeps a socket open for live messages.',
        Icons.devices_rounded,
        at(0.5, 0.08),
        const Color(0xFF3B82F6),
      );
      final laravel = _Node(
        'Laravel API',
        'Auth · chats · messages',
        'Source of truth: users, memberships and message history.',
        Icons.dns_rounded,
        at(0.22, 0.42),
        const Color(0xFFF05340),
      );
      final gateway = _Node(
        'Node.js gateway',
        'Express 5 · Socket.IO 4',
        'Holds the live connections and fans messages out to members.',
        Icons.bolt_rounded,
        at(0.78, 0.42),
        const Color(0xFF4CAF50),
      );
      final db = _Node(
        'Database',
        'Users · chats · messages',
        'Relational schema written through Laravel only.',
        Icons.storage_rounded,
        at(0.22, 0.76),
        const Color(0xFF6366F1),
      );
      final peers = _Node(
        'Chat members',
        'Receive instantly',
        'Other clients in the same chat.',
        Icons.groups_rounded,
        at(0.78, 0.76),
        const Color(0xFF3B82F6),
      );

      final links = <_Link>[
        _link(client, laravel, box, accent, label: 'REST + token'),
        _link(client, gateway, box, _wsColor,
            both: true, phase: 0.25, label: 'WebSocket'),
        _link(gateway, laravel, box, accent, phase: 0.5, label: 'auth'),
        _link(laravel, db, box, accent, phase: 0.1, label: 'Eloquent'),
        _link(gateway, peers, box, _wsColor, phase: 0.6, label: 'broadcast'),
      ];

      return Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _LinkPainter(links, flow)),
          ),
          for (final l in links) _LinkLabel(link: l),
          for (final n in [client, laravel, gateway, db, peers])
            _NodeCard(node: n, size: box),
          Positioned(
            left: 0,
            right: 0,
            bottom: 6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendDot(color: accent, text: 'REST (HTTP)'),
                const SizedBox(width: 18),
                const _LegendDot(color: _wsColor, text: 'Real-time (WebSocket)'),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendDot({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withOpacity(0.7), blurRadius: 6)],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.6)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  View 2 – Data model
// ─────────────────────────────────────────────────────────────

class _DataModelView extends StatelessWidget {
  final Color accent;
  const _DataModelView({super.key, required this.accent});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final h = c.maxHeight;
      final box = Size(math.min(150.0, w * 0.38), 58);
      Offset at(double fx, double fy) => Offset(w * fx, h * fy);

      _Node table(String name, String caption, Offset p, Color color) => _Node(
            name,
            caption,
            caption,
            Icons.table_rows_rounded,
            p,
            color,
          );

      final users = table('users', 'accounts', at(0.24, 0.10), const Color(0xFF6366F1));
      final chats = table('chats', 'group or private', at(0.76, 0.10), const Color(0xFF0EA5E9));
      final member = table('chat_user', 'membership · admin', at(0.5, 0.33), accent);
      final messages = table('messages', 'chat history', at(0.76, 0.57), const Color(0xFF22C55E));
      final reads = table('messages_read', 'read receipts', at(0.24, 0.57), const Color(0xFF16A34A));

      final links = <_Link>[
        _link(users, member, box, Colors.white, flow: false, label: '1 : N'),
        _link(chats, member, box, Colors.white, flow: false, label: '1 : N'),
        _link(chats, messages, box, Colors.white, flow: false, label: '1 : N'),
        _link(messages, reads, box, Colors.white, flow: false, label: '1 : N'),
        _link(users, reads, box, Colors.white, flow: false, label: '1 : N'),
      ];

      return Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _LinkPainter(links, null))),
          for (final l in links) _LinkLabel(link: l),
          for (final n in [users, chats, member, messages, reads])
            _NodeCard(node: n, size: box),
          Positioned(
            left: 12,
            right: 12,
            bottom: 8,
            child: Text(
              'Many-to-many membership through a pivot table, with read state '
              'tracked per user per message.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                height: 1.45,
                color: Colors.white.withOpacity(0.55),
              ),
            ),
          ),
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────
//  View switch
// ─────────────────────────────────────────────────────────────

class _ViewSwitch extends StatelessWidget {
  final int index;
  final List<String> labels;
  final Color accent;
  final ValueChanged<int> onChanged;

  const _ViewSwitch({
    required this.index,
    required this.labels,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 0.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < labels.length; i++)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(17),
                    gradient: i == index
                        ? LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              accent.withOpacity(0.5),
                              accent.withOpacity(0.22),
                            ],
                          )
                        : null,
                    border: Border.all(
                      color: i == index
                          ? Colors.white.withOpacity(0.55)
                          : Colors.transparent,
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: i == index ? FontWeight.w600 : FontWeight.w400,
                      color: Colors.white.withOpacity(i == index ? 1 : 0.65),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
