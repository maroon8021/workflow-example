import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi";
import "@typespec/openapi3";

using TypeSpec.Http;
using TypeSpec.Rest;
using TypeSpec.OpenAPI;

@service({
  title: "Workflow Example API",
})
@server("http://localhost:3001", "Development server")
namespace WorkflowExample;

@route("/")
namespace Root {
  @get
  op getRoot(): {
    @statusCode statusCode: 200;
    @body body: {
      message: string;
    };
  };

  @route("/health")
  @get
  op getHealth(): {
    @statusCode statusCode: 200;
    @body body: {
      status: "ok";
    };
  };
}

@route("/users")
namespace Users {
  model User {
    id: string;
    email: string;
    name: string | null;
    createdAt: utcDateTime;
    updatedAt: utcDateTime;
  }

  model CreateUserRequest {
    email: string;
    name?: string;
  }

  @get
  op listUsers(): {
    @statusCode statusCode: 200;
    @body body: {
      users: User[];
    };
  };

  @post
  op createUser(@body body: CreateUserRequest): {
    @statusCode statusCode: 201;
    @body body: User;
  };

  @route("/{id}")
  @get
  op getUser(@path id: string): {
    @statusCode statusCode: 200;
    @body body: User;
  };
}
