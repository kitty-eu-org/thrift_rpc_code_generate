namespace go schema
namespace py schema

struct Request {
 1: required string aa;
}

struct Response {
 1: required string aa;
}

service ServiceExample {
Response Sayhello(1:Request request);
}
