/**
 * Error handling utilities for the frontend application
 */

// Custom error types
export class NetworkError extends Error {
  public statusCode?: number;
  public response?: Response;

  constructor(message: string, statusCode?: number, response?: Response) {
    super(message);
    this.name = 'NetworkError';
    this.statusCode = statusCode;
    this.response = response;
  }
}

export class ValidationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'ValidationError';
  }
}

export class UnauthorizedError extends Error {
  constructor(message: string = 'Unauthorized access') {
    super(message);
    this.name = 'UnauthorizedError';
  }
}

// Error handler class
class ErrorHandler {
  private static instance: ErrorHandler;
  private errorHandlers: Map<string, (error: Error) => void>;

  private constructor() {
    this.errorHandlers = new Map();
  }

  public static getInstance(): ErrorHandler {
    if (!ErrorHandler.instance) {
      ErrorHandler.instance = new ErrorHandler();
    }
    return ErrorHandler.instance;
  }

  /**
   * Register an error handler for a specific error type
   */
  public registerHandler(errorType: string, handler: (error: Error) => void): void {
    this.errorHandlers.set(errorType, handler);
  }

  /**
   * Handle an error based on its type
   */
  public handleError(error: Error): void {
    console.error('Error occurred:', error);

    // Check for registered handlers
    const handler = this.errorHandlers.get(error.name);
    if (handler) {
      handler(error);
      return;
    }

    // Default error handling
    this.defaultErrorHandler(error);
  }

  /**
   * Default error handler
   */
  private defaultErrorHandler(error: Error): void {
    // Log error to console
    console.error('Unhandled error:', error);

    // Show user-friendly message
    let userMessage = 'An unexpected error occurred. Please try again.';

    if (error instanceof NetworkError) {
      if (error.statusCode === 401) {
        userMessage = 'Your session has expired. Please log in again.';
        // Redirect to login page
        setTimeout(() => {
          localStorage.removeItem('access_token');
          window.location.href = '/login';
        }, 1000);
      } else if (error.statusCode === 403) {
        userMessage = 'You do not have permission to perform this action.';
      } else if (error.statusCode === 404) {
        userMessage = 'The requested resource was not found.';
      } else if (error.statusCode >= 500) {
        userMessage = 'A server error occurred. Please try again later.';
      } else {
        userMessage = `Request failed: ${error.message}`;
      }
    } else if (error instanceof ValidationError) {
      userMessage = `Validation error: ${error.message}`;
    }

    // Display error to user (using toast or modal)
    this.showUserError(userMessage);
  }

  /**
   * Show error to user in a user-friendly way
   */
  private showUserError(message: string): void {
    // In a real implementation, this would use your UI's notification system
    // For example, using sonner toast: toast.error(message)
    console.warn('User-facing error:', message);
  }

  /**
   * Log error to external service
   */
  public logError(error: Error, context?: Record<string, any>): void {
    // In a real implementation, this would send error to external logging service
    // Example: Sentry.captureException(error, { contexts: context });
    console.group('Error Details');
    console.error('Message:', error.message);
    console.error('Stack:', error.stack);
    if (context) {
      console.error('Context:', context);
    }
    console.groupEnd();
  }
}

// Export singleton instance
export const errorHandler = ErrorHandler.getInstance();

/**
 * Higher-order function to wrap async functions with error handling
 */
export function withErrorHandling<T extends (...args: any[]) => Promise<any>>(
  fn: T,
  context?: Record<string, any>
): T {
  return ((...args: any[]) => {
    return fn(...args).catch((error: Error) => {
      // Log the error with context
      errorHandler.logError(error, {
        function: fn.name,
        args: args,
        ...context
      });

      // Handle the error appropriately
      errorHandler.handleError(error);

      // Re-throw the error so calling code can handle it if needed
      throw error;
    });
  }) as T;
}

/**
 * Utility to create a safe wrapper for API calls
 */
export async function safeApiCall<T>(
  apiCall: () => Promise<T>,
  options: {
    onError?: (error: Error) => void;
    onSuccess?: (result: T) => void;
    context?: Record<string, any>;
  } = {}
): Promise<T | null> {
  try {
    const result = await apiCall();
    if (options.onSuccess) {
      options.onSuccess(result);
    }
    return result;
  } catch (error) {
    // Log the error with context
    errorHandler.logError(error as Error, options.context);

    // Handle the error
    if (options.onError) {
      options.onError(error as Error);
    } else {
      errorHandler.handleError(error as Error);
    }

    return null;
  }
}

/**
 * Utility to check if error is a network error
 */
export function isNetworkError(error: unknown): error is NetworkError {
  return error instanceof NetworkError;
}

/**
 * Utility to check if error is a validation error
 */
export function isValidationError(error: unknown): error is ValidationError {
  return error instanceof ValidationError;
}

/**
 * Utility to check if error is an unauthorized error
 */
export function isUnauthorizedError(error: unknown): error is UnauthorizedError {
  return error instanceof UnauthorizedError;
}