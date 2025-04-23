// Define constants for Sheet ID and Sheet Name
const SHEET_ID = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
const SHEET_NAME = "XXXXXXXXXXXXXXXXXX";

function doPost(request) {
    // Validate required parameters
    const requiredParams = ["spreadsheetId", "sheetName", "values"];
    const missingParams = requiredParams.filter((param) => !request.parameter[param]);
  
    if (missingParams.length > 0) {
      return createErrorResponse(`Missing parameters: ${missingParams.join(", ")}`);
    }
  
    const sheetId = request.parameter.spreadsheetId;
    const sheetName = request.parameter.sheetName;
  
    // Validate Sheet ID and Sheet Name
    if (sheetId !== SHEET_ID) {
      return createErrorResponse("Invalid Sheet ID provided.");
    }
    if (sheetName !== SHEET_NAME) {
      return createErrorResponse("Invalid Sheet Name provided.");
    }
  
    try {
      const sheet = SpreadsheetApp.openById(sheetId).getSheetByName(sheetName);
      const values = JSON.parse(request.parameter.values); // New data to add
  
      // Get all existing data from the sheet
      const existingData = sheet.getDataRange().getValues().map((row) => row[0]); // Assuming keywords are in the first column
  
      // Filter out keywords that already exist in the sheet
      const newValues = values.filter((row) => !existingData.includes(row[0]));
  
      if (newValues.length > 0) {
        // Append only new rows to the sheet
        sheet.getRange(sheet.getLastRow() + 1, 1, newValues.length, 1).setValues(newValues);
      }
  
      return createSuccessResponse("New keywords added successfully.");
    } catch (error) {
      return createErrorResponse(error.toString());
    }
  }


function doGet(request) {
  // Validate required parameters
  const requiredParams = ["spreadsheetId", "sheetName"];
  const missingParams = requiredParams.filter((param) => !request.parameter[param]);

  if (missingParams.length > 0) {
    return createErrorResponse(`Missing parameters: ${missingParams.join(", ")}`);
  }

  const sheetId = request.parameter.spreadsheetId;
  const sheetName = request.parameter.sheetName;

  // Validate Sheet ID and Sheet Name
  if (sheetId !== SHEET_ID) {
    return createErrorResponse("Invalid Sheet ID provided.");
  }
  if (sheetName !== SHEET_NAME) {
    return createErrorResponse("Invalid Sheet Name provided.");
  }

  try {
    const sheet = SpreadsheetApp.openById(sheetId).getSheetByName(sheetName);
    const all = request.parameter.all === "true";
    let values;

    if (all) {
      // Fetch all data from the sheet
      values = sheet.getDataRange().getValues();
    } else {
      // Fetch specific range of data
      const row = parseInt(request.parameter.row, 10) || 1;
      const column = parseInt(request.parameter.column, 10) || 1;
      const rowNumbers = parseInt(request.parameter.rowNumbers, 10) || sheet.getLastRow();
      const columnNumbers = parseInt(request.parameter.columnNumbers, 10) || sheet.getLastColumn();
      values = sheet.getRange(row, column, rowNumbers, columnNumbers).getValues();
    }

    return createSuccessResponse("Data fetched successfully.", { data: values });
  } catch (error) {
    return createErrorResponse(error.toString());
  }
}

// Helper function to create a success response
function createSuccessResponse(message, additionalData = {}) {
  return ContentService.createTextOutput(
    JSON.stringify({ status: "SUCCESS", message, ...additionalData })
  ).setMimeType(ContentService.MimeType.JSON);
}

// Helper function to create an error response
function createErrorResponse(message) {
  return ContentService.createTextOutput(
    JSON.stringify({ status: "FAILED", message })
  ).setMimeType(ContentService.MimeType.JSON);
}