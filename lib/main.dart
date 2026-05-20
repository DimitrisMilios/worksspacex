import 'package:flutter/material.dart';
import 'features/workspaces/providers/workspace_provider.dart';
import 'features/workspaces/widgets/workspace_list_view.dart';
import 'features/workspaces/widgets/add_workspace_dialog.dart';

void main() {
  runApp(const WorkSpaceXApp());
}

class WorkSpaceXApp extends StatelessWidget {
  const WorkSpaceXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WorkSpaceX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xff6200ee),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xff6200ee),
          secondary: Color(0xff03dac6),
        ),
        scaffoldBackgroundColor: const Color(0xff121212),
        useMaterial3: true,
      ),
      home: const ExtensionContainer(),
    );
  }
}

class ExtensionContainer extends StatefulWidget {
  const ExtensionContainer({super.key});

  @override
  State<ExtensionContainer> createState() => _ExtensionContainerState();
}

class _ExtensionContainerState extends State<ExtensionContainer> {
  late final WorkspaceProvider _workspaceProvider;

  @override
  void initState() {
    super.initState();
    _workspaceProvider = WorkspaceProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 400,
        height: 550,
        child: ListenableBuilder(
          listenable: _workspaceProvider,
          builder: (context, _) {
            if (_workspaceProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _workspaceProvider.workspaces.isEmpty
                      ? _buildEmptyState()
                      : WorkspaceListView(
                          workspaces: _workspaceProvider.workspaces,
                          onDelete: _workspaceProvider.deleteWorkspace,
                          onLaunch: _workspaceProvider.launchWorkspace,
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddWorkspaceDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xff121212),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xff6200ee).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome_motion_rounded, 
              color: Color(0xff03dac6), size: 22),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WorkSpaceX',
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Restoring Context Instantly',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white38,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {}, // Future settings
            icon: Icon(Icons.tune_rounded, 
              color: Colors.white.withOpacity(0.4), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.workspaces_outline, size: 48, 
                color: Colors.white.withOpacity(0.1)),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Workspaces Found',
              style: TextStyle(
                color: Colors.white, 
                fontSize: 18, 
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a group of URLs to launch them all at once.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4), 
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showAddWorkspaceDialog(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('New Workspace'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff6200ee),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWorkspaceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddWorkspaceDialog(
        onAdd: (name, urls) {
          _workspaceProvider.addWorkspace(name, urls);
        },
      ),
    );
  }
}
