/**
 * State management utilities for the frontend application
 */

// Generic state manager interface
interface StateManager<T> {
  getState(): T;
  setState(newState: Partial<T> | ((prevState: T) => T)): void;
  subscribe(listener: () => void): () => void;
  unsubscribe(listener: () => void): void;
}

// Local storage utility
class LocalStorageUtil {
  private static readonly PREFIX = 'taskflow_';

  static getItem<T>(key: string, defaultValue: T): T {
    try {
      const item = localStorage.getItem(this.PREFIX + key);
      return item ? JSON.parse(item) : defaultValue;
    } catch (error) {
      console.warn(`Error reading from localStorage for key "${key}":`, error);
      return defaultValue;
    }
  }

  static setItem<T>(key: string, value: T): void {
    try {
      localStorage.setItem(this.PREFIX + key, JSON.stringify(value));
    } catch (error) {
      console.warn(`Error saving to localStorage for key "${key}":`, error);
    }
  }

  static removeItem(key: string): void {
    try {
      localStorage.removeItem(this.PREFIX + key);
    } catch (error) {
      console.warn(`Error removing from localStorage for key "${key}":`, error);
    }
  }
}

// State persistence manager
class StatePersistenceManager<T> {
  private key: string;
  private listeners: Array<() => void> = [];

  constructor(key: string, initialState: T) {
    this.key = key;

    // Initialize with persisted state if available
    const persistedState = LocalStorageUtil.getItem<T>(key, initialState);
    this.setState(persistedState);
  }

  getState(): T {
    return LocalStorageUtil.getItem<T>(this.key, {} as T);
  }

  setState(newState: Partial<T> | ((prevState: T) => T)): void {
    const currentState = this.getState();
    const newStateValue = typeof newState === 'function' ? newState(currentState) : { ...currentState, ...newState };

    LocalStorageUtil.setItem(this.key, newStateValue);

    // Notify listeners
    this.listeners.forEach(listener => listener());
  }

  subscribe(listener: () => void): () => void {
    this.listeners.push(listener);

    // Return unsubscribe function
    return () => {
      this.listeners = this.listeners.filter(l => l !== listener);
    };
  }

  unsubscribe(listener: () => void): void {
    this.listeners = this.listeners.filter(l => l !== listener);
  }
}

// Task state manager
class TaskStateManager {
  private persistenceManager: StatePersistenceManager<{ tasks: any[] }>;
  private listeners: Array<() => void> = [];

  constructor() {
    this.persistenceManager = new StatePersistenceManager('tasks', { tasks: [] });
  }

  getTasks(): any[] {
    const state = this.persistenceManager.getState();
    return state.tasks || [];
  }

  setTasks(tasks: any[]): void {
    this.persistenceManager.setState({ tasks });
  }

  addTask(task: any): void {
    const currentTasks = this.getTasks();
    this.setTasks([...currentTasks, task]);
  }

  updateTask(updatedTask: any): void {
    const currentTasks = this.getTasks();
    const updatedTasks = currentTasks.map(task =>
      task.id === updatedTask.id ? updatedTask : task
    );
    this.setTasks(updatedTasks);
  }

  deleteTask(taskId: string): void {
    const currentTasks = this.getTasks();
    const updatedTasks = currentTasks.filter(task => task.id !== taskId);
    this.setTasks(updatedTasks);
  }

  subscribe(listener: () => void): () => void {
    return this.persistenceManager.subscribe(listener);
  }

  clearTasks(): void {
    this.setTasks([]);
  }
}

// Singleton instances
const taskStateManager = new TaskStateManager();

// Export the task state manager
export { taskStateManager, StatePersistenceManager, LocalStorageUtil };

// Hook-style function for React components (to be used in components)
export function useTaskState() {
  const [tasks, setTasks] = [taskStateManager.getTasks(), (newTasks: any[]) => taskStateManager.setTasks(newTasks)];

  const addTask = (task: any) => {
    taskStateManager.addTask(task);
  };

  const updateTask = (updatedTask: any) => {
    taskStateManager.updateTask(updatedTask);
  };

  const deleteTask = (taskId: string) => {
    taskStateManager.deleteTask(taskId);
  };

  const subscribe = (listener: () => void) => {
    return taskStateManager.subscribe(listener);
  };

  return {
    tasks,
    setTasks,
    addTask,
    updateTask,
    deleteTask,
    subscribe
  };
}

// Debounced state update utility
export function debounceStateUpdate<T>(
  setState: (newState: T) => void,
  delay: number = 300
): (newState: T) => void {
  let timeoutId: NodeJS.Timeout | null = null;

  return (newState: T) => {
    if (timeoutId) {
      clearTimeout(timeoutId);
    }

    timeoutId = setTimeout(() => {
      setState(newState);
      timeoutId = null;
    }, delay);
  };
}

// Batch state updates utility
export class BatchUpdater<T> {
  private state: T;
  private listeners: Array<(state: T) => void> = [];
  private batchQueue: Array<Partial<T> | ((prevState: T) => T)> = [];
  private batchTimeout: NodeJS.Timeout | null = null;

  constructor(initialState: T) {
    this.state = { ...initialState };
  }

  getState(): T {
    return { ...this.state };
  }

  setState(newState: Partial<T> | ((prevState: T) => T)): void {
    this.batchQueue.push(newState);

    if (this.batchTimeout) {
      clearTimeout(this.batchTimeout);
    }

    this.batchTimeout = setTimeout(() => {
      this.processBatch();
    }, 0); // Process on next tick
  }

  private processBatch(): void {
    let newState = { ...this.state };

    for (const update of this.batchQueue) {
      if (typeof update === 'function') {
        newState = { ...newState, ...update(newState) };
      } else {
        newState = { ...newState, ...update };
      }
    }

    this.state = newState;
    this.batchQueue = [];

    // Notify listeners
    this.listeners.forEach(listener => listener(this.state));
  }

  subscribe(listener: (state: T) => void): () => void {
    this.listeners.push(listener);

    return () => {
      this.listeners = this.listeners.filter(l => l !== listener);
    };
  }

  unsubscribe(listener: (state: T) => void): void {
    this.listeners = this.listeners.filter(l => l !== listener);
  }
}