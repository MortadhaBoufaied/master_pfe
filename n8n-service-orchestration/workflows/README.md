# N8N Workflows Documentation

## Overview

This directory contains n8n workflow templates for service execution. Each workflow corresponds to a registered service in the service registry.

## Workflow Structure

Each workflow follows this general pattern:

1. **Webhook Trigger**: Receives service request from chatbot
2. **Extract Parameters**: Parses and validates incoming parameters
3. **Backend Call**: Calls backend API to perform the service
4. **Format Response**: Transforms backend response into user-friendly format
5. **Error Handling**: Catches and handles any errors

## Available Workflows

### get-user-profile.json
- **Trigger**: `POST /webhook/get-user-profile`
- **Purpose**: Retrieve user profile information
- **Backend Endpoint**: `GET /api/users/{user_id}`
- **Response Template**: `profile_card`

### book-appointment.json
- **Trigger**: `POST /webhook/book-appointment`
- **Purpose**: Book an appointment with a service
- **Backend Endpoint**: `POST /api/appointments`
- **Parameters**: service_type, date, time, notes
- **Response Template**: `booking_confirmation`

### get-schedule.json
- **Trigger**: `POST /webhook/get-schedule`
- **Purpose**: Get available time slots
- **Backend Endpoint**: `GET /api/availability`
- **Parameters**: service_type, duration_minutes, days_ahead
- **Response Template**: `schedule_list`

### submit-feedback.json
- **Trigger**: `POST /webhook/submit-feedback`
- **Purpose**: Submit user feedback or complaints
- **Backend Endpoint**: `POST /api/feedback`
- **Parameters**: message, rating, category
- **Response Template**: `feedback_confirmation`

### get-payment-status.json
- **Trigger**: `POST /webhook/get-payment-status`
- **Purpose**: Check payment or invoice status
- **Backend Endpoint**: `GET /api/payments/{user_id}`
- **Response Template**: `payment_status`

### cancel-appointment.json
- **Trigger**: `POST /webhook/cancel-appointment`
- **Purpose**: Cancel an existing appointment
- **Backend Endpoint**: `DELETE /api/appointments/{appointment_id}`
- **Parameters**: appointment_id, reason
- **Response Template**: `cancellation_confirmation`

### get-service-details.json
- **Trigger**: `POST /webhook/get-service-details`
- **Purpose**: Get detailed service information
- **Backend Endpoint**: `GET /api/services/{service_name}`
- **Response Template**: `service_details`

### track-order.json
- **Trigger**: `POST /webhook/track-order`
- **Purpose**: Track order or request status
- **Backend Endpoint**: `GET /api/orders/{order_id}`
- **Parameters**: order_id
- **Response Template**: `order_tracking`

### get-faq.json
- **Trigger**: `POST /webhook/get-faq`
- **Purpose**: Get FAQ information
- **Backend Endpoint**: `GET /api/faq`
- **Parameters**: category, search_term
- **Response Template**: `faq_list`

## Importing Workflows

1. In n8n UI, click "+" to create new workflow
2. Click "Import from JSON"
3. Select workflow JSON file
4. Configure webhook URL (should match service ID)
5. Update backend API endpoints
6. Test workflow
7. Deploy

## Creating New Workflows

1. Use `base-service-executor.json` as template
2. Replace backend endpoint
3. Implement custom parameter extraction if needed
4. Add error handling
5. Test thoroughly
6. Document in this file

## Testing Workflows

### Manual Test in n8n
1. Open workflow
2. Click "Webhook" node
3. Click "Test" tab
4. Send test request with sample data
5. Check response

### API Test
```bash
curl -X POST http://localhost:5678/webhook/get-user-profile \
  -H "Content-Type: application/json" \
  -d '{
    "service_id": "get-user-profile",
    "parameters": {"user_id": "123"},
    "timestamp": "2026-05-08T10:00:00Z"
  }'
```

## Error Handling

Each workflow should include error handling:

- **Connection Error**: Log and return error message
- **Invalid Parameters**: Return validation error
- **Backend Error**: Return backend error or generic error message
- **Timeout**: Return timeout error with retry suggestion

## Performance Considerations

- Set appropriate timeout values (usually 5-10 seconds)
- Use caching for frequently accessed data
- Batch API calls when possible
- Monitor execution time and optimize queries

## Security

- Validate all parameters
- Use API keys for backend authentication
- Encrypt sensitive data
- Log security events
- Implement rate limiting

## Debugging

Enable debug logs in n8n:
- Open workflow
- Click settings gear icon
- Enable "Debug Mode"
- Run workflow and check execution tab

## Best Practices

1. Keep workflows simple and focused
2. Use meaningful node names
3. Add comments for complex logic
4. Test error scenarios
5. Document parameter requirements
6. Monitor execution logs
7. Version control workflows

## Next Steps

1. Implement all example workflows
2. Test with real backend
3. Set up monitoring and alerts
4. Create custom workflows for your services
5. Document custom workflows
