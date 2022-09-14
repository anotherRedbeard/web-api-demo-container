namespace TodoApi.Models
{
    public class TodoItemDTO
    {
        public TodoItemDTO()
        {
        }
        public TodoItemDTO(TodoItem todoItem)
        {
            Id = todoItem.Id;
            Name = todoItem.Name;
            IsComplete = todoItem.IsComplete;
        }
        public long Id { get; set; }
        public string? Name { get; set; }
        public bool IsComplete { get; set; }
    }
}