
import { GoogleGenAI, Type } from "@google/genai";

export async function getCycleAdvice(day: number, isPeriod: boolean) {
  const ai = new GoogleGenAI({ apiKey: process.env.API_KEY || "" });
  
  const prompt = `User is on day ${day} of their menstrual cycle. Current state: ${isPeriod ? 'During Period' : 'Follicular/Luteal Phase'}. 
  Provide 3 short, warm, and professional health tips for this specific stage. Include one nutritional tip, one lifestyle tip, and one emotional well-being tip.
  The tone should be friendly, like a supportive elder sister (Auntie).`;

  try {
    const response = await ai.models.generateContent({
      model: 'gemini-3-flash-preview',
      contents: prompt,
      config: {
        responseMimeType: "application/json",
        responseSchema: {
          type: Type.OBJECT,
          properties: {
            tips: {
              type: Type.ARRAY,
              items: {
                type: Type.OBJECT,
                properties: {
                  category: { type: Type.STRING },
                  content: { type: Type.STRING }
                },
                required: ["category", "content"]
              }
            },
            summary: { type: Type.STRING }
          },
          required: ["tips", "summary"]
        }
      }
    });

    return JSON.parse(response.text);
  } catch (error) {
    console.error("Gemini API Error:", error);
    return null;
  }
}
