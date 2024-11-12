// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:support_sphere/utils/supabase.dart';

class ChecklistService {
  // final SupabaseClient _supabaseClient = supabase;

  Future<List<Map<String, dynamic>>> getUserChecklists(String userId) async {
    return [
      {
        "id": "78b00368-02e0-4e0d-a68c-8d08b123e083",
        "title": "Personal Emergency Preparedness",
        "description":
            "This checklist helps individuals prepare for a variety of emergency situations, from natural disasters to unexpected crises, ensuring they have the necessary resources and plans in place to stay safe.",
        "checklist_steps": [
          {
            "step": "Assemble an Emergency Kit",
            "description":
                "Collect essential supplies like food, water, medications, flashlights, and a first aid kit. Aim for a 72-hour supply to sustain you during the initial phase of an emergency."
          },
          {
            "step": "Create a Family Communication Plan",
            "description":
                "Establish a way to communicate with family members during an emergency, including identifying a central contact person outside the area for everyone to check in with."
          },
          {
            "step": "Know Your Local Risks",
            "description":
                "Identify specific risks in your area, such as hurricanes, earthquakes, or flooding, to better tailor your emergency preparations."
          },
          {
            "step": "Learn Basic First Aid and CPR",
            "description":
                "Familiarize yourself with first aid and CPR techniques, which can be crucial during emergencies if immediate medical help isn’t available."
          },
          {
            "step": "Secure Important Documents",
            "description":
                "Gather and protect important documents, like identification, insurance policies, and medical records, storing them in a waterproof, fireproof container."
          }
        ],
        "last_completed_version": 1,
        "frequency": {
          "name": "Yearly",
        },
        "user_checklist_state": {
          "completed": true,
          "completed_at": DateTime.now().toString(),
        }
      },
      {
        "id": "edd1062d-0d1e-4b07-ab13-6775bf876a60",
        "title": "Workplace Emergency Preparedness",
        "description":
            "This checklist is designed for businesses and organizations to help staff prepare for emergencies, minimizing risk and ensuring a quick, organized response to keep everyone safe.",
        "checklist_steps": [
          {
            "step": "Develop an Emergency Response Plan",
            "description":
                "Create a comprehensive response plan detailing evacuation routes, shelter-in-place procedures, and communication protocols."
          },
          {
            "step": "Conduct Regular Drills",
            "description":
                "Schedule drills for various scenarios like fire, earthquake, or active shooter situations to ensure employees know what to do in an emergency."
          },
          {
            "step": "Establish a Communication Chain",
            "description":
                "Identify key personnel responsible for communicating updates during an emergency and establish clear methods for reaching all employees."
          }
        ],
        "last_completed_version": 0,
        "frequency": {
          "name": "Once",
        },
        "user_checklist_state": {
          "completed": true,
          "completed_at": DateTime.now().toString(),
        }
      }
    ];
    /// TBD: on hold and wait until the PR is merged: https://github.com/uw-ssec/post-disaster-comms/pull/182
    // return await _supabaseClient
    //     .from('user_checklists')
    //     .select('''
    //       id,
    //       checklist_type:checklist_types (
    //         id,
    //         title,
    //         description,
    //         recurring_type:recurring_types (
    //           name,
    //           num_days
    //         ),
    //         checklist_steps_order (
    //           checklist_steps_templates_id
    //         )
    //       ),
    //       due_date,
    //       last_completed_version,
    //       user_checklist_state (
    //         completed,
    //         completed_at
    //       )
    //     ''')
    //     .eq('user_id', userId)
    //     .order('due_date', ascending: true);
  }
}
