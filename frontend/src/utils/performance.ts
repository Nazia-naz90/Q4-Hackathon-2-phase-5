/**
 * Performance monitoring utilities for the frontend application
 */

// Performance monitoring class
class PerformanceMonitor {
  private static instance: PerformanceMonitor;
  private marks: Map<string, number>;
  private measures: Map<string, number>;

  private constructor() {
    this.marks = new Map();
    this.measures = new Map();
  }

  public static getInstance(): PerformanceMonitor {
    if (!PerformanceMonitor.instance) {
      PerformanceMonitor.instance = new PerformanceMonitor();
    }
    return PerformanceMonitor.instance;
  }

  /**
   * Start measuring performance for a specific operation
   */
  public startMark(markName: string): void {
    this.marks.set(markName, performance.now());
  }

  /**
   * End measuring performance for a specific operation
   */
  public endMark(markName: string): number | null {
    const startTime = this.marks.get(markName);
    if (startTime === undefined) {
      console.warn(`Performance mark "${markName}" was not started`);
      return null;
    }

    const duration = performance.now() - startTime;
    this.measures.set(markName, duration);

    // Log performance if it exceeds threshold (e.g., 100ms)
    if (duration > 100) {
      console.warn(`Performance warning: "${markName}" took ${duration.toFixed(2)}ms`);
    }

    return duration;
  }

  /**
   * Get average performance for a specific operation
   */
  public getAverageMeasure(markName: string): number | null {
    const durations = Array.from(this.measures.entries())
      .filter(([key]) => key.startsWith(markName))
      .map(([, duration]) => duration);

    if (durations.length === 0) {
      return null;
    }

    return durations.reduce((sum, duration) => sum + duration, 0) / durations.length;
  }

  /**
   * Clear all performance data
   */
  public clear(): void {
    this.marks.clear();
    this.measures.clear();
  }

  /**
   * Get all performance measures
   */
  public getAllMeasures(): Map<string, number> {
    return new Map(this.measures);
  }
}

// Export singleton instance
export const perfMonitor = PerformanceMonitor.getInstance();

/**
 * Higher-order function to wrap async functions with performance monitoring
 */
export function withPerformanceTracking<T extends (...args: any[]) => Promise<any>>(
  fn: T,
  operationName: string
): T {
  return ((...args: any[]) => {
    perfMonitor.startMark(operationName);
    return fn(...args).finally(() => {
      const duration = perfMonitor.endMark(operationName);
      if (duration !== null) {
        // Optionally send performance data to analytics
        // sendPerformanceData(operationName, duration);
      }
    });
  }) as T;
}

/**
 * Hook to measure render performance (to be used in React components)
 */
export function useRenderPerformance(componentName: string): void {
  if (typeof window !== 'undefined') {
    const markName = `render-${componentName}-${Date.now()}`;
    perfMonitor.startMark(markName);

    // In a real React component, you would use useEffect to end the mark
    // after the component has rendered
    setTimeout(() => {
      perfMonitor.endMark(markName);
    }, 0);
  }
}

/**
 * Send performance data to analytics (placeholder implementation)
 */
export function sendPerformanceData(operationName: string, duration: number): void {
  // In a real implementation, you would send this to your analytics service
  // Example: analytics.track('performance', { operationName, duration });
  console.debug(`Performance data: ${operationName} took ${duration.toFixed(2)}ms`);
}