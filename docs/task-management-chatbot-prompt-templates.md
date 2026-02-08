# Task Management Chatbot - Prompt Templates

## 1. Add New Task Prompt Template
```
I want to add a new task. Use the 'Add Task' tool with the following parameters:

Title: [Task Name goes here]
Description: [Detailed description of what needs to be done]
Priority: [High/Medium/Low or 1-5 scale]
Due Date: [YYYY-MM-DD format if applicable]
Category: [Work, Personal, Urgent, etc.]
Status: Pending

Please execute this action and return the Task ID once it is successfully created in the database.
```

## 2. Update Existing Task Prompt Template
```
I need to update a specific task. First, find the task named '[Task Name]'. Once found, use the 'Update Task' function to change its [Field Name, e.g., Status, Priority, Due Date] to '[New Value]'.

Important: Do not just say it's updated; verify the change by fetching the task details again and showing them to me. Confirm the update was successful.
```

## 3. Search Tasks Prompt Template
```
Please find all tasks that match the following criteria:
- Status: [Pending, In Progress, Completed, etc.]
- Category: [Work, Personal, etc.]
- Priority: [High, Medium, Low]
- Due Date: [Before/after specific date or range]

Show me the relevant tasks with their details.
```

## 4. Complete Task Prompt Template
```
I want to mark the following task as completed: '[Task Name or ID]'. Update the status to 'Completed' and record the completion date as today. Please verify the change and confirm the task is now marked as completed.
```

## 5. List All Tasks Prompt Template
```
Please show me all my tasks, organized by:
- Status (group pending, in progress, completed)
- Priority (high priority first)
- Due date (soonest first)

Include the Task ID, Title, Status, Priority, and Due Date for each task.
```

## 6. Delete Task Prompt Template
```
I want to delete the following task: '[Task Name or ID]'. Before deleting, please show me the current task details for confirmation. Once confirmed, proceed with deletion and confirm the task has been removed.
```

## 7. Create Recurring Task Prompt Template
```
I want to create a recurring task with these specifications:
Title: [Task Name]
Description: [Description]
Frequency: [Daily/Weekly/Monthly]
Priority: [High/Medium/Low]
Category: [Category]

Please create this recurring task and provide the master task ID.
```

## 8. Get Task Details Prompt Template
```
Please show me all details for task ID '[Task ID]' or task name '[Task Name]'. Include status, priority, due date, creation date, last updated, and any notes or subtasks associated with it.
```

## Best Practices for Using These Prompts:
1. Replace placeholder text (enclosed in []) with actual values
2. Be specific with task names to avoid confusion
3. Always verify important changes by requesting confirmation
4. Use consistent terminology for categories and priorities
5. Include due dates in YYYY-MM-DD format for clarity