package com.moa.model;

public class Todo {
    private int todoId;
    private int storeId;
    private String content;
    private boolean done;

    public int getTodoId() { return todoId; }
    public void setTodoId(int todoId) { this.todoId = todoId; }
    public int getStoreId() { return storeId; }
    public void setStoreId(int storeId) { this.storeId = storeId; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public boolean isDone() { return done; }
    public void setDone(boolean done) { this.done = done; }
}
