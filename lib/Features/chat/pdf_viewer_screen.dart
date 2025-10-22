import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PDFViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String fileName;

  const PDFViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.fileName,
  });

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  int _viewerAttempt = 0; // 0: Google Docs, 1: Mozilla PDF.js, 2: Direct URL

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    final encodedUrl = Uri.encodeComponent(widget.pdfUrl);
    String viewerUrl;
    
    if (_viewerAttempt == 0) {
      // Try Google Docs Viewer first
      viewerUrl = 'https://docs.google.com/gview?embedded=true&url=$encodedUrl';
      print('🔍 PDF Viewer: Attempt ${_viewerAttempt + 1} - Google Docs Viewer');
    } else if (_viewerAttempt == 1) {
      // Try Mozilla PDF.js viewer
      viewerUrl = 'https://mozilla.github.io/pdf.js/web/viewer.html?file=$encodedUrl';
      print('🔍 PDF Viewer: Attempt ${_viewerAttempt + 1} - Mozilla PDF.js');
    } else {
      // Try direct URL
      viewerUrl = widget.pdfUrl;
      print('🔍 PDF Viewer: Attempt ${_viewerAttempt + 1} - Direct URL');
    }
    
    print('🔍 PDF Viewer: Original URL: ${widget.pdfUrl}');
    print('🔍 PDF Viewer: Viewer URL: $viewerUrl');
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('📄 PDF Viewer: Page started loading: $url');
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (String url) {
            print('✅ PDF Viewer: Page finished loading');
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ PDF Viewer Error:');
            print('   Code: ${error.errorCode}');
            print('   Description: ${error.description}');
            print('   Type: ${error.errorType}');
            
            // Try next viewer method if available
            if (_viewerAttempt < 2) {
              print('🔄 Trying alternative viewer...');
              setState(() {
                _viewerAttempt++;
              });
              Future.delayed(Duration(milliseconds: 100), () {
                _initializeWebView();
              });
            } else {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(viewerUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.fileName,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF1A1B4B),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'open_browser',
            backgroundColor: Colors.blue,
            child: Icon(Icons.open_in_browser, color: Colors.white),
            onPressed: _openInBrowser,
            tooltip: 'Open in Browser',
          ),
          SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'download',
            backgroundColor: Colors.green,
            child: Icon(Icons.download, color: Colors.white),
            onPressed: _downloadPDF,
            tooltip: 'Download PDF',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_hasError) {
      return _buildErrorView();
    }

    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.8),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading PDF...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _getViewerName(),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Or tap the button below to open in browser',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _getViewerName() {
    switch (_viewerAttempt) {
      case 0:
        return 'Using Google Docs Viewer';
      case 1:
        return 'Using Mozilla PDF.js Viewer';
      case 2:
        return 'Loading Direct URL';
      default:
        return 'Loading...';
    }
  }

  Widget _buildErrorView() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 80,
            ),
            SizedBox(height: 16),
            Text(
              'Failed to load PDF',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'The PDF could not be displayed in the viewer. Try opening it in your browser instead.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _retryLoading,
                  icon: Icon(Icons.refresh),
                  label: Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _openInBrowser,
                  icon: Icon(Icons.open_in_browser),
                  label: Text('Open in Browser'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _downloadPDF() async {
    try {
      final uri = Uri.parse(widget.pdfUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('Cannot open PDF URL');
      }
    } catch (e) {
      _showSnackBar('Error opening PDF: $e');
    }
  }

  void _openInBrowser() async {
    try {
      final uri = Uri.parse(widget.pdfUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('Cannot open PDF in browser');
      }
    } catch (e) {
      _showSnackBar('Error opening PDF: $e');
    }
  }

  void _retryLoading() {
    setState(() {
      _hasError = false;
      _isLoading = true;
      _viewerAttempt = 0; // Reset to try Google Docs viewer again
    });
    _initializeWebView();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
