import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// شاشة البث المباشر - YouTube Live
class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  final List<Map<String, dynamic>> _liveStreams = [
    {
      'title': 'درس النحو - المستوى الأول',
      'teacher': 'أستاذ محمد أحمد الوهيدي',
      'status': 'live', // live, upcoming, ended
      'viewers': 245,
      'thumbnail': 'https://img.youtube.com/vi/EXAMPLE1/maxresdefault.jpg',
      'url': 'https://youtube.com/live/EXAMPLE1',
      'scheduledTime': DateTime.now(),
    },
    {
      'title': 'شرح الإعراب - المستوى الثاني',
      'teacher': 'أستاذ محمد أحمد الوهيدي',
      'status': 'upcoming',
      'viewers': 0,
      'thumbnail': 'https://img.youtube.com/vi/EXAMPLE2/maxresdefault.jpg',
      'url': 'https://youtube.com/live/EXAMPLE2',
      'scheduledTime': DateTime.now().add(const Duration(hours: 2)),
    },
    {
      'title': 'مراجعة البلاغة - المستوى الثالث',
      'teacher': 'أستاذ محمد أحمد الوهيدي',
      'status': 'ended',
      'viewers': 1200,
      'thumbnail': 'https://img.youtube.com/vi/EXAMPLE3/maxresdefault.jpg',
      'url': 'https://youtube.com/watch?v=EXAMPLE3',
      'scheduledTime': DateTime.now().subtract(const Duration(hours: 5)),
    },
  ];

  String _selectedFilter = 'الكل';

  final List<String> _filters = ['الكل', 'مباشر', 'قادم', 'سابق'];

  /// فتح رابط البث
  Future<void> _openStream(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ لا يمكن فتح الرابط'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// تفعيل تذكير
  void _setReminder(Map<String, dynamic> stream) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🔔 سيتم تذكيرك قبل بداية: ${stream['title']}'),
        backgroundColor: const Color(0xFFD4AF37),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredStreams = _selectedFilter == 'الكل'
        ? _liveStreams
        : _liveStreams.where((s) {
            switch (_selectedFilter) {
              case 'مباشر':
                return s['status'] == 'live';
              case 'قادم':
                return s['status'] == 'upcoming';
              case 'سابق':
                return s['status'] == 'ended';
              default:
                return true;
            }
          }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'البث المباشر',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        actions: [
          // مؤشر البث المباشر
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // فلاتر
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = filter == _selectedFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFFD4AF37),
                    backgroundColor: const Color(0xFF2A2A2A),
                    onSelected: (_) => setState(() => _selectedFilter = filter),
                  ),
                );
              },
            ),
          ),

          // قائمة البث
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredStreams.length,
              itemBuilder: (context, index) {
                return _buildStreamCard(filteredStreams[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamCard(Map<String, dynamic> stream) {
    final status = stream['status'] as String;
    final isLive = status == 'live';
    final isUpcoming = status == 'upcoming';
    final isEnded = status == 'ended';

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isLive) {
      statusColor = Colors.red;
      statusText = 'مباشر الآن';
      statusIcon = Icons.videocam;
    } else if (isUpcoming) {
      statusColor = Colors.orange;
      statusText = 'قادم';
      statusIcon = Icons.schedule;
    } else {
      statusColor = Colors.grey;
      statusText = 'انتهى';
      statusIcon = Icons.check_circle;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isLive ? Colors.red.withOpacity(0.5) : Colors.white24,
        ),
      ),
      child: InkWell(
        onTap: () => _openStream(stream['url']),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Stack(
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF2A2A2A),
                        const Color(0xFF1A1A1A),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 60,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
                
                // Status badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          statusText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Viewers (للبث المباشر)
                if (isLive && stream['viewers'] > 0)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.visibility,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${stream['viewers']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            
            // معلومات البث
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stream['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'الأستاذ: ${stream['teacher']}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      if (isUpcoming) ...[
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.orange.withOpacity(0.7),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'يبدأ بعد ${_formatDuration(stream['scheduledTime'].difference(DateTime.now()))}',
                          style: TextStyle(
                            color: Colors.orange.withOpacity(0.7),
                            fontSize: 14,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ] else if (isEnded) ...[
                        Icon(
                          Icons.history,
                          size: 16,
                          color: Colors.grey.withOpacity(0.7),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'انتهى ${_formatDuration(DateTime.now().difference(stream['scheduledTime']))} مضت',
                          style: TextStyle(
                            color: Colors.grey.withOpacity(0.7),
                            fontSize: 14,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                      const Spacer(),
                      
                      // زر التذكير أو المشاهدة
                      if (isUpcoming)
                        ElevatedButton.icon(
                          onPressed: () => _setReminder(stream),
                          icon: const Icon(Icons.notifications_active, size: 16),
                          label: const Text(
                            'تذكير',
                            style: TextStyle(fontFamily: 'Cairo', fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        )
                      else if (isLive || isEnded)
                        ElevatedButton.icon(
                          onPressed: () => _openStream(stream['url']),
                          icon: Icon(
                            isLive ? Icons.videocam : Icons.play_arrow,
                            size: 16,
                          ),
                          label: Text(
                            isLive ? 'شاهد الآن' : 'مشاهدة',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isLive ? Colors.red : const Color(0xFFD4AF37),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
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
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} يوم';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} ساعة';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} دقيقة';
    } else {
      return 'قريباً';
    }
  }
}