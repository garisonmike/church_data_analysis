import 'package:flutter/material.dart';

/// Explains every financial component tracked by the app.
/// Accessible from the financial charts screen and weekly entry screen.
class FinancialGlossaryScreen extends StatelessWidget {
  const FinancialGlossaryScreen({super.key});

  static const _terms = [
    _GlossaryTerm(
      icon: Icons.account_balance,
      color: Color(0xFF1565C0),
      title: 'Tithe',
      formula: '10% of gross income',
      description:
          'A biblical principle where members return 10% of their income to God through the church. '
          'In the SDA Church, tithe is forwarded to the Conference (e.g. South Kenya Conference) '
          'and does not remain with the local church. It funds pastors, evangelism, and administration.',
      sdaNote: 'SDA-specific: Tithe belongs to the Conference, not the local church budget.',
    ),
    _GlossaryTerm(
      icon: Icons.volunteer_activism,
      color: Color(0xFF00796B),
      title: 'Offerings',
      formula: 'Voluntary contributions',
      description:
          'Freewill offerings given during the Sabbath service, separate from tithe. '
          'These remain with the local church and fund local ministry, outreach, and operations. '
          'Includes Sabbath School offerings, church budget, and special collections.',
      sdaNote: 'Stays with the local church, unlike tithe.',
    ),
    _GlossaryTerm(
      icon: Icons.crisis_alert,
      color: Color(0xFFC62828),
      title: 'Emergency Collection',
      formula: 'Special one-off collection',
      description:
          'A targeted, unplanned collection taken for an urgent need — e.g. a member\'s medical bill, '
          'a disaster relief effort, or an unexpected church expense. Approved by the board.',
      sdaNote: 'Should be recorded with the purpose in the notes field.',
    ),
    _GlossaryTerm(
      icon: Icons.event_note,
      color: Color(0xFF6A1B9A),
      title: 'Planned Collection',
      formula: 'Pre-announced targeted collection',
      description:
          'A collection announced in advance for a specific known project — e.g. building fund, '
          'toilet renovation, benches. Different from emergency in that the congregation is informed beforehand.',
      sdaNote: 'Use the notes field to record the specific project name.',
    ),
    _GlossaryTerm(
      icon: Icons.public,
      color: Color(0xFF2E7D32),
      title: 'Mission Offering',
      formula: 'Designated giving for world mission',
      description:
          'Contributions directed to global SDA mission work. Includes 13th Sabbath Offering '
          '(quarterly), Ingathering, and World Budget. These are forwarded to the General Conference '
          'through the Conference and Division.',
      sdaNote: '13th Sabbath: every 13th Sabbath of a quarter has a special offering for a world division.',
    ),
    _GlossaryTerm(
      icon: Icons.home_work,
      color: Color(0xFF00838F),
      title: 'Local Church Budget',
      formula: 'Operational church fund',
      description:
          'The portion of offerings designated for local church running costs — utilities, '
          'maintenance, stationery, and other day-to-day expenses. '
          'Managed and approved by the local church board.',
      sdaNote: 'Distinct from tithe and conference-directed funds.',
    ),
    _GlossaryTerm(
      icon: Icons.trending_up,
      color: Color(0xFF4527A0),
      title: 'Total Income',
      formula: 'Tithe + Offerings + Emergency + Planned + Mission + Local Budget',
      description:
          'The sum of all giving streams recorded for a given week. '
          'Note that not all of this stays with the local church — tithe and mission offerings '
          'are remitted to the Conference.',
      sdaNote: 'For local budget planning, use Offerings + Planned Collection + Local Church Budget only.',
    ),
    _GlossaryTerm(
      icon: Icons.people,
      color: Color(0xFF558B2F),
      title: 'Income per Attendee',
      formula: 'Total Income ÷ Total Attendance',
      description:
          'A derived metric showing the average giving per person who attended that week. '
          'Useful for identifying unusual weeks (very high or very low). '
          'Tracks spiritual health of giving culture in the congregation.',
      sdaNote: 'Used internally for trend analysis. Not a target-setting figure.',
    ),
    _GlossaryTerm(
      icon: Icons.school,
      color: Color(0xFF795548),
      title: 'Sabbath School Attendance',
      formula: 'Count of SS members present',
      description:
          'The number of members who attend Sabbath School (Bible study classes before the main service). '
          'Tracked separately because SS attendance is often higher or lower than the main service. '
          'A key indicator of spiritual engagement.',
      sdaNote: 'SDA churches run Sabbath School from ~9:30 AM before the 11 AM main service.',
    ),
    _GlossaryTerm(
      icon: Icons.directions_walk,
      color: Color(0xFF0288D1),
      title: 'Visitors Count',
      formula: 'Non-member attendees',
      description:
          'The number of guests and non-members who attended that Sabbath. '
          'Tracked to monitor outreach effectiveness and first-time visitor trends.',
      sdaNote: 'Visitors are recorded under the VISITORS home church in event attendance.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Financial & Data Glossary')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withAlpha(100),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'This glossary explains every metric tracked by the app and how each is calculated. '
                  'SDA-specific notes are highlighted in teal.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ]),
          ),
          ..._terms.map((term) => _GlossaryCard(term: term)),
        ],
      ),
    );
  }
}

class _GlossaryTerm {
  final IconData icon;
  final Color color;
  final String title, formula, description;
  final String? sdaNote;

  const _GlossaryTerm({
    required this.icon,
    required this.color,
    required this.title,
    required this.formula,
    required this.description,
    this.sdaNote,
  });
}

class _GlossaryCard extends StatefulWidget {
  final _GlossaryTerm term;
  const _GlossaryCard({required this.term});

  @override
  State<_GlossaryCard> createState() => _GlossaryCardState();
}

class _GlossaryCardState extends State<_GlossaryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.term;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: t.color.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(t.icon, color: t.color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    Text(t.formula, style: TextStyle(fontSize: 12, color: t.color, fontFamily: 'monospace')),
                  ],
                )),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey),
              ]),
              if (_expanded) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Text(t.description, style: const TextStyle(fontSize: 13, height: 1.5)),
                if (t.sdaNote != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0d9488).withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF0d9488).withAlpha(60)),
                    ),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Icon(Icons.church, size: 14, color: Color(0xFF0d9488)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(t.sdaNote!,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF0d9488), height: 1.4))),
                    ]),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
