import 'package:flutter/foundation.dart';
import 'package:social_media_app/Features/feed/model/twitter_comment_model.dart';
import 'package:social_media_app/Features/feed/repository/twitter_comment_repository.dart';

/// View model for Twitter-style comments
class TwitterCommentViewModel extends ChangeNotifier {
  final TwitterCommentRepository _repository = TwitterCommentRepository();

  // State
  List<TwitterCommentModel> _comments = [];
  Map<String, List<TwitterCommentModel>> _replies = {};
  Map<String, List<TwitterCommentModel>> _threads = {};
  bool _isLoading = false;
  String? _error;
  Map<String, bool> _isInteracting = {};

  // Getters
  List<TwitterCommentModel> get comments => _comments;
  Map<String, List<TwitterCommentModel>> get replies => _replies;
  Map<String, List<TwitterCommentModel>> get threads => _threads;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool isInteracting(String commentId) => _isInteracting[commentId] ?? false;

  /// Load comments for a post
  Future<void> loadComments(String postId) async {
    _setLoading(true);
    _clearError();

    try {
      _repository.getComments(postId).listen(
        (comments) {
          _comments = comments;
          notifyListeners();
        },
        onError: (error) {
          _setError('Failed to load comments: $error');
        },
      );
    } catch (e) {
      _setError('Failed to load comments: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load replies for a comment
  Future<void> loadReplies(String postId, String parentCommentId) async {
    try {
      _repository.getReplies(postId, parentCommentId).listen(
        (replies) {
          _replies[parentCommentId] = replies;
          notifyListeners();
        },
        onError: (error) {
          debugPrint('Failed to load replies: $error');
        },
      );
    } catch (e) {
      debugPrint('Failed to load replies: $e');
    }
  }

  /// Load comment thread
  Future<void> loadCommentThread(String postId, String rootCommentId) async {
    try {
      _repository.getCommentThread(postId, rootCommentId).listen(
        (threadComments) {
          _threads[rootCommentId] = threadComments;
          notifyListeners();
        },
        onError: (error) {
          debugPrint('Failed to load thread: $error');
        },
      );
    } catch (e) {
      debugPrint('Failed to load thread: $e');
    }
  }

  /// Add a new comment
  Future<bool> addComment({
    required String postId,
    required String text,
    String? parentCommentId,
    String? replyToCommentId,
    String? replyToUserName,
    List<String>? mediaUrls,
    String mediaType = 'text',
    String? quotedCommentId,
    Map<String, dynamic>? quotedCommentData,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.addComment(
        postId: postId,
        text: text,
        parentCommentId: parentCommentId,
        replyToCommentId: replyToCommentId,
        replyToUserName: replyToUserName,
        mediaUrls: mediaUrls,
        mediaType: mediaType,
        quotedCommentId: quotedCommentId,
        quotedCommentData: quotedCommentData,
      );

      // Reload comments to get the new comment
      await loadComments(postId);
      
      // If this was a reply, reload replies for the parent comment
      if (parentCommentId != null) {
        await loadReplies(postId, parentCommentId);
      }

      return true;
    } catch (e) {
      _setError('Failed to add comment: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Like/unlike a comment
  Future<bool> toggleLike(String postId, String commentId) async {
    _setInteracting(commentId, true);

    try {
      await _repository.toggleLike(postId, commentId);
      
      // Update local state
      _updateCommentInList(commentId, (comment) {
        final likes = List<String>.from(comment.likes);
        if (likes.contains(comment.userId)) {
          likes.remove(comment.userId);
        } else {
          likes.add(comment.userId);
        }
        return comment.copyWith(likes: likes);
      });

      return true;
    } catch (e) {
      _setError('Failed to toggle like: $e');
      return false;
    } finally {
      _setInteracting(commentId, false);
    }
  }

  /// Retweet/unretweet a comment
  Future<bool> toggleRetweet(String postId, String commentId) async {
    _setInteracting(commentId, true);

    try {
      await _repository.toggleRetweet(postId, commentId);
      
      // Update local state
      _updateCommentInList(commentId, (comment) {
        final retweets = List<String>.from(comment.retweets);
        if (retweets.contains(comment.userId)) {
          retweets.remove(comment.userId);
        } else {
          retweets.add(comment.userId);
        }
        return comment.copyWith(retweets: retweets);
      });

      return true;
    } catch (e) {
      _setError('Failed to toggle retweet: $e');
      return false;
    } finally {
      _setInteracting(commentId, false);
    }
  }

  /// Save/unsave a comment
  Future<bool> toggleSave(String postId, String commentId) async {
    _setInteracting(commentId, true);

    try {
      await _repository.toggleSave(postId, commentId);
      
      // Update local state
      _updateCommentInList(commentId, (comment) {
        final saves = List<String>.from(comment.saves);
        if (saves.contains(comment.userId)) {
          saves.remove(comment.userId);
        } else {
          saves.add(comment.userId);
        }
        return comment.copyWith(saves: saves);
      });

      return true;
    } catch (e) {
      _setError('Failed to toggle save: $e');
      return false;
    } finally {
      _setInteracting(commentId, false);
    }
  }

  /// Increment view count
  Future<void> incrementViewCount(String postId, String commentId) async {
    try {
      await _repository.incrementViewCount(postId, commentId);
      
      // Update local state
      _updateCommentInList(commentId, (comment) {
        return comment.copyWith(viewCount: comment.viewCount + 1);
      });
    } catch (e) {
      debugPrint('Failed to increment view count: $e');
    }
  }

  /// Edit a comment
  Future<bool> editComment(String postId, String commentId, String newText) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.editComment(postId, commentId, newText);
      
      // Update local state
      _updateCommentInList(commentId, (comment) {
        return comment.copyWith(
          text: newText,
          isEdited: true,
          editedAt: DateTime.now(),
        );
      });

      return true;
    } catch (e) {
      _setError('Failed to edit comment: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a comment
  Future<bool> deleteComment(String postId, String commentId) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.deleteComment(postId, commentId);
      
      // Remove from local state
      _comments.removeWhere((comment) => comment.commentId == commentId);
      
      // Remove from replies
      _replies.remove(commentId);
      
      // Remove from threads
      _threads.remove(commentId);

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete comment: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get comment by ID
  Future<TwitterCommentModel?> getComment(String postId, String commentId) async {
    try {
      return await _repository.getComment(postId, commentId);
    } catch (e) {
      _setError('Failed to get comment: $e');
      return null;
    }
  }

  /// Search comments
  Future<void> searchComments(String postId, String query) async {
    if (query.trim().isEmpty) {
      await loadComments(postId);
      return;
    }

    try {
      _repository.searchComments(postId, query).listen(
        (searchResults) {
          _comments = searchResults;
          notifyListeners();
        },
        onError: (error) {
          _setError('Search failed: $error');
        },
      );
    } catch (e) {
      _setError('Search failed: $e');
    }
  }

  /// Clear error
  void clearError() {
    _clearError();
  }

  /// Refresh comments
  Future<void> refresh(String postId) async {
    await loadComments(postId);
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void _setInteracting(String commentId, bool interacting) {
    _isInteracting[commentId] = interacting;
    notifyListeners();
  }

  void _updateCommentInList(String commentId, TwitterCommentModel Function(TwitterCommentModel) updater) {
    // Update in main comments list
    for (int i = 0; i < _comments.length; i++) {
      if (_comments[i].commentId == commentId) {
        _comments[i] = updater(_comments[i]);
        break;
      }
    }

    // Update in replies
    _replies.forEach((parentId, replies) {
      for (int i = 0; i < replies.length; i++) {
        if (replies[i].commentId == commentId) {
          replies[i] = updater(replies[i]);
          break;
        }
      }
    });

    // Update in threads
    _threads.forEach((threadId, threadComments) {
      for (int i = 0; i < threadComments.length; i++) {
        if (threadComments[i].commentId == commentId) {
          threadComments[i] = updater(threadComments[i]);
          break;
        }
      }
    });

    notifyListeners();
  }
}
