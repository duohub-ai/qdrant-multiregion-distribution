#!/bin/sh

# Check if required arguments are provided
if [ $# -ne 3 ]; then
    echo "Usage: $0 <transit_gateway_id> <route_table_id> <region>"
    exit 1
fi

TGW_ID=$1
ROUTE_TABLE_ID=$2
REGION=$3
# Function to set the default route table
set_default_tgw_route_table() {
    echo "Setting $ROUTE_TABLE_ID as the default route table for Transit Gateway $TGW_ID..."
    
    aws ec2 modify-transit-gateway \
        --transit-gateway-id $TGW_ID \
        --region $REGION \
        --options "{
            \"DefaultRouteTableAssociation\": \"enable\",
            \"AssociationDefaultRouteTableId\": \"$ROUTE_TABLE_ID\",
            \"DefaultRouteTablePropagation\": \"enable\",
            \"PropagationDefaultRouteTableId\": \"$ROUTE_TABLE_ID\"
        }"
    
    if [ $? -eq 0 ]; then
        echo "Successfully set $ROUTE_TABLE_ID as the default route table for Transit Gateway $TGW_ID"
    else
        echo "Error setting default route table. Please check your AWS CLI configuration and permissions."
        exit 1
    fi
}

# Call the function
set_default_tgw_route_table