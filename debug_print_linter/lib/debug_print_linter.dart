import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart' as e;
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_dart.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

PluginBase createPlugin() => _DebugPrintLinter();

/// A plugin class is used to list all the assists/lints defined by a plugin.
class _DebugPrintLinter extends PluginBase {
  /// We list all the custom warnings/infos/errors
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
    DebugPrintCustomLintCode(),
  ];
}

class DebugPrintCustomLintCode extends DartLintRule {
  const DebugPrintCustomLintCode()
    : super(
        code: const LintCode(
          name: 'my_custom_lint',
          correctionMessage: 'This is the description of our custom lint',
          errorSeverity: e.ErrorSeverity.WARNING,
          problemMessage: 'Avoid using print statements in production code.',
        ),
      );
  @override
  List<Fix> getFixes() => <Fix>[UseDeveloperLogFix()];
  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      // We get the static element of the method name node.
      final Element? element = node.methodName.staticElement;

      // Check if the method's element is a FunctionElement.
      if (element is! FunctionElement) return;

      // Check if the method name is 'print'.
      if (element.name != 'debugPrint' && element.name != 'print') return;

      // Check if the method's library is 'dart:core'.
      if (!element.library.isDartCore) return;

      // Report the lint error for the method invocation node.
      reporter.atNode(node, code);
    });
  }
}

class UseDeveloperLogFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    e.AnalysisError analysisError,
    List<e.AnalysisError> others,
  ) {
    // Register a callback for each method invocation in the file.
    context.registry.addMethodInvocation((node) {
      // If the method invocation does not intersect with the analysis error, return.
      if (!node.sourceRange.intersects(analysisError.sourceRange)) return;

      // Create a ChangeBuilder to apply the quick fix.
      // The message is displayed in the quick fix menu.
      // The priority determines the order of the quick fixes in the menu.
      final ChangeBuilder changeBuilder = reporter.createChangeBuilder(
        message: 'Use log from package:logger_utils/logger.dart instead.',
        priority: 80,
      );

      // Here we use the addDartFileEdit method to apply the quick fix.
      changeBuilder.addDartFileEdit((DartFileEditBuilder builder) {
        // Get the source range of the method name node.
        final SourceRange sourceRange;
        // = node.methodName.sourceRange;
        if (node is IndexExpression) {
          sourceRange = fn(node as IndexExpression);
        } else {
          sourceRange = node.methodName.sourceRange;
        }
        // Here we ensure that the developer package is imported.
        // It will import the package if it is not already imported.
        // If the package is already imported, it will return a ImportLibraryElementResult object.
        final ImportLibraryElementResult result = builder.importLibraryElement(
          Uri.parse('package:logger_utils/logger.dart'),
        );

        // Get the library prefix if the package is imported.
        final String? prefix = result.prefix;

        // Get the replacement string based on the library prefix.
        final String replacement =
            prefix != null ? '$prefix.logger.debug' : 'logger.debug';

        // Replace the print statement with log.
        builder.addSimpleReplacement(sourceRange, replacement);
      });
    });
  }

  SourceRange fn(IndexExpression node) {
    final SourceRange sourceRange = range.startEnd(
      node.leftBracket,
      node.rightBracket,
    );
    return sourceRange;
  }
}
