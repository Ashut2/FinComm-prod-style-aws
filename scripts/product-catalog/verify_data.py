import sys; sys.path.insert(0,".")
### `sys.path.insert` tells python "also look in this folder to import." Needed bcz `demo_pb2` isn't a real installed package, it's just a `.py` file sitting there 
import grpc, demo_pb2, demo_pb2_grpc
### grpc - networking library that speaks gRPC , the protocol our Go service uses 
### demo_pb2, demo_pb2_grpc - loads the generated code that knows the shape of every message and service from demo.proto


channel = grpc.insecure_channel('localhost:3550')
### Opens a plain, unencrypted connection to our container. 'Insecure' here just means no TLS, and its not needed for local dev. 

stub = demo_pb2_grpc.ProductCatalogServiceStub(channel)
### `demo_pb2_grpc.productcatalogservicestub(channel)` buils a "remote control" Object, calling a method on stub actually sends a network request to the container. 

response = stub.ListProducts(demo_pb2.Empty(), timeout=15)
### `demo_pb2.Empty()` builds the request. `ListPrducts` taks no real input,so this is genuinely an empty message, matching what we can see in the proto file

### stub.ListProducts(...)sends the request and blocks unti it gets a reply or times out. 

print("number  of products:", len(response.products))
print("first product:", response.products[0].name)

### The two print lines shows us the real data that came back, not just an empty success 
