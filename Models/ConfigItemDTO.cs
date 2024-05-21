namespace TodoApi.Models
{
    public class ConfigItemDTO
    {
        public ConfigItemDTO()
        {
        }

        public ConfigItemDTO(string message)
        {
            Message = message;
        }
        public string? Message { get; set; }
    }
}