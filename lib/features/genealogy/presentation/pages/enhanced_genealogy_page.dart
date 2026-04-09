import 'package:flutter/material.dart';
import '../../services/genealogy_service.dart';

/// Enhanced Genealogy Page with visual family tree
class GenealogyPage extends StatefulWidget {
  const GenealogyPage({super.key});

  @override
  State<GenealogyPage> createState() => _GenealogyPageState();
}

class _GenealogyPageState extends State<GenealogyPage> {
  final GenealogyService _service = GenealogyService();
  bool _isLoading = true;
  String _selectedView = 'tree'; // tree, lineage, tribes, patriarchs
  GenealogyPerson? _selectedPerson;
  // ignore: unused_field
  String _searchQuery = '';
  // ignore: unused_field
  List<GenealogyPerson> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _service.load();
    setState(() => _isLoading = false);
  }

  void _search(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = _service.search(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblical Genealogy'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // View selector
                _buildViewSelector(),
                
                // Main content
                Expanded(
                  child: _buildContent(),
                ),
                
                // Selected person details
                if (_selectedPerson != null)
                  _buildPersonDetails(),
              ],
            ),
    );
  }

  Widget _buildViewSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'tree',
              label: Text('Tree'),
              icon: Icon(Icons.account_tree),
            ),
            ButtonSegment(
              value: 'lineage',
              label: Text('Lineage'),
              icon: Icon(Icons.line_axis),
            ),
            ButtonSegment(
              value: 'tribes',
              label: Text('12 Tribes'),
              icon: Icon(Icons.groups),
            ),
            ButtonSegment(
              value: 'patriarchs',
              label: Text('Patriarchs'),
              icon: Icon(Icons.star),
            ),
          ],
          selected: {_selectedView},
          onSelectionChanged: (Set<String> selected) {
            setState(() {
              _selectedView = selected.first;
              _selectedPerson = null;
            });
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedView) {
      case 'tree':
        return _buildFamilyTree();
      case 'lineage':
        return _buildLineageView();
      case 'tribes':
        return _buildTribesView();
      case 'patriarchs':
        return _buildPatriarchsView();
      default:
        return _buildFamilyTree();
    }
  }

  Widget _buildFamilyTree() {
    final all = _service.getAllPeople();
    if (all.isEmpty) return const Center(child: Text('No data available'));

    final maxGeneration = all.fold<int>(0, (max, p) => p.generation > max ? p.generation : max);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Generational Tree',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap a person to view details. This view is optimized for mobile readability.',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        for (int generation = 1; generation <= maxGeneration; generation++)
          _buildGenerationSection(generation),
      ],
    );
  }

  Widget _buildGenerationSection(int generation) {
    final people = _service.getByGeneration(generation);
    if (people.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Generation $generation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: people.map((person) {
                final isSelected = _selectedPerson?.id == person.id;
                return ChoiceChip(
                  label: Text(person.name),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedPerson = person),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineageView() {
    final lineage = _service.getLineageOfJesus();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lineage.length,
      itemBuilder: (context, index) {
        final person = lineage[index];
        final isSelected = _selectedPerson?.id == person.id;

        return TimelineTile(
          isFirst: index == 0,
          isLast: index == lineage.length - 1,
          index: index + 1,
          child: GestureDetector(
            onTap: () => setState(() => _selectedPerson = person),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (person.isPatriarch)
                        const Icon(Icons.star, size: 20, color: Colors.amber),
                      if (person.isPatriarch) const SizedBox(width: 8),
                      Text(
                        person.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Gen ${person.generation}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  if (person.title.isNotEmpty)
                    Text(
                      person.title,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  if (person.lifespan.isNotEmpty)
                    Text(
                      person.lifespan,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTribesView() {
    final tribes = _service.getTwelveTribes();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: tribes.length,
      itemBuilder: (context, index) {
        final tribe = tribes[index];
        final isSelected = _selectedPerson?.id == tribe.id;

        return GestureDetector(
          onTap: () => setState(() => _selectedPerson = tribe),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.withValues(alpha: 0.2),
                  Colors.blue.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.blue.withValues(alpha: 0.3),
                width: isSelected ? 3 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  tribe.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tribe.title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPatriarchsView() {
    final patriarchs = _service.getPatriarchs();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: patriarchs.length,
      itemBuilder: (context, index) {
        final patriarch = patriarchs[index];
        final isSelected = _selectedPerson?.id == patriarch.id;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: isSelected ? 4 : 1,
          color: isSelected ? Colors.amber.withValues(alpha: 0.15) : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.amber,
              child: const Icon(Icons.star, color: Colors.white),
            ),
            title: Text(
              patriarch.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patriarch.title),
                if (patriarch.lifespan.isNotEmpty)
                  Text(
                    patriarch.lifespan,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
              ],
            ),
            isThreeLine: patriarch.lifespan.isNotEmpty,
            onTap: () => setState(() => _selectedPerson = patriarch),
          ),
        );
      },
    );
  }

  Widget _buildPersonDetails() {
    final person = _selectedPerson!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: person.isPatriarch
                      ? Colors.amber
                      : person.isTribe
                          ? Colors.blue
                          : Theme.of(context).colorScheme.primary,
                  child: Icon(
                    person.isPatriarch
                        ? Icons.star
                        : person.isTribe
                            ? Icons.groups
                            : Icons.person,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        person.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        person.title,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _selectedPerson = null),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Details
            if (person.description != null)
              Text(
                person.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            if (person.description != null) const SizedBox(height: 12),

            // Scripture reference
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.menu_book,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      person.scripture,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (person.lifespan.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    person.lifespan,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.account_tree,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  'Generation ${person.generation}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Genealogy'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter name...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: _search,
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Custom timeline tile widget
class TimelineTile extends StatelessWidget {
  final Widget child;
  final bool isFirst;
  final bool isLast;
  final int index;

  const TimelineTile({
    super.key,
    required this.child,
    required this.isFirst,
    required this.isLast,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          // Timeline line and dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: 2,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: 2,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(child: child),
        ],
      ),
    );
  }
}
