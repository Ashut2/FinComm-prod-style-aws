# Python Script to verify the internal connection between product catalog service & recommendation service; ListRecommendation should output the product ids if everything is working.

# we have to answer following questions

# Where do I connect?

# localhost:9550; scipts run on my computer, and compose maps this port to the recommendation container's port 9001

# What small request do I send?

# `ListRecommendations` with `product_ids=[]` - ask for recommendations without excluding any products.

# What response counts as success?

# one or more id's in response.product_ids - the service found products and returned recomendations

# How will the script signal pass or fail?

# print the IDs and exit successfully on a valid response; print an error and exit nonzero if the call fails or returns no IDs


import grpc
import demo_pb2
import demo_pb2_grpc

SERVICE_ADDRESS = "localhost:9550"

def main():
    channel = grpc.insecure_channel(SERVICE_ADDRESS)
    clients = demo_pb2_grpc.RecommendationServiceStub(channel)   # depends on HTTP, gRPC, etc.
    request = demo_pb2.ListRecommendationsRequest(product_ids=[])
    response = clients.ListRecommendations(request, timeout=5)   # use the service's real API
    if len(response.product_ids) == 0:     # define success for this service
        raise SystemExit("FAIL: zero products; coudln't reach producy-catalog service")
    print(list(response.product_ids))

if __name__ == "__main__":
    main()
