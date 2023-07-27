variable "rules" {
  type = list(object({
    port        = number
    eport       = number
    proto       = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      port        = 80
      eport       = 80
      proto       = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 22
      eport       = 22
      proto       = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 0
      eport       = 65000
      proto       = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    }
  ]


}



variable "kubecname" {
  description = "Cluster hostname"
  default     = ""
}
