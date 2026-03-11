// Re-exports ClientsListScreen so the router import remains valid.
export 'package:ca_app/features/clients/presentation/clients_list_screen.dart'
    show ClientsListScreen;

// Alias for backward compatibility with router reference.
import 'package:ca_app/features/clients/presentation/clients_list_screen.dart';

typedef ClientsScreen = ClientsListScreen;
